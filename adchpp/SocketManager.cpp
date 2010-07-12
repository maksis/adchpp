/*
 * Copyright (C) 2006-2010 Jacek Sieka, arnetheduck on gmail point com
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#include "adchpp.h"

#include "SocketManager.h"

#include "LogManager.h"
#include "TimerManager.h"
#include "ManagedSocket.h"
#include "ServerInfo.h"
#include "SimpleXML.h"

#ifdef HAVE_OPENSSL
#include <boost/asio/ssl.hpp>
#endif
#include <boost/date_time/posix_time/time_parsers.hpp>

namespace adchpp {

using namespace std;
using namespace std::placeholders;
using namespace boost::asio;
using boost::system::error_code;
using boost::system::system_error;

SocketManager::SocketManager()  {

}

SocketManager::~SocketManager() {

}

SocketManager* SocketManager::instance = 0;
const string SocketManager::className = "SocketManager";

template<typename T>
class SocketStream : public AsyncStream {
public:
	template<typename X>
	SocketStream(X& x) : sock(x) { }

	template<typename X, typename Y>
	SocketStream(X& x, Y& y) : sock(x, y) {
	}

	virtual void read(const BufferPtr& buf, const Handler& handler) {
		sock.async_read_some(boost::asio::buffer(buf->data(), buf->size()), handler);
	}

	virtual void write(const BufferList& bufs, const Handler& handler) {
		if(true || bufs.size() == 1) {
			sock.async_write_some(boost::asio::buffer(bufs[0]->data(), bufs[0]->size()), handler);
		} else {
			size_t n = std::min(bufs.size(), static_cast<size_t>(64));
			std::vector<boost::asio::const_buffer> buffers;
			buffers.reserve(n);

			const size_t maxBytes = 64*1024;

			for(size_t i = 0, total = 0; i < n && total < maxBytes; ++i) {
				size_t left = maxBytes - total;
				size_t bytes = bufs[i]->size() > left ? left : bufs[i]->size();
				buffers.push_back(boost::asio::const_buffer(bufs[i]->data(), bytes));
				total += bytes;
			}

			sock.async_write_some(buffers, handler);
		}
	}

	virtual void close() {
		// Abortive close, just go away...
		if(sock.lowest_layer().is_open()) {
			sock.lowest_layer().set_option(socket_base::linger(true, 10));
			sock.lowest_layer().close();
		}
	}

	T sock;
};

typedef SocketStream<ip::tcp::socket> SimpleSocketStream;

#ifdef HAVE_OPENSSL
typedef SocketStream<ssl::stream<ip::tcp::socket> > TLSSocketStream;
#endif

class SocketFactory : public intrusive_ptr_base<SocketFactory> {
public:
	SocketFactory(io_service& io_, const SocketManager::IncomingHandler& handler_, const ServerInfoPtr& info) :
		io(io_),
		acceptor(io_, ip::tcp::endpoint(boost::asio::ip::tcp::v4(), info->port)),
		serverInfo(info),
		handler(handler_)
	{
#ifdef HAVE_OPENSSL
		if(info->secure()) {
			context.reset(new boost::asio::ssl::context(io, ssl::context::tlsv1_server));
		    context->set_options(
		        boost::asio::ssl::context::no_sslv2
		        | boost::asio::ssl::context::no_sslv3
		        | boost::asio::ssl::context::single_dh_use);
		    //context->set_password_callback(boost::bind(&server::get_password, this));
		    context->use_certificate_chain_file(info->TLSParams.cert);
		    context->use_private_key_file(info->TLSParams.pkey, boost::asio::ssl::context::pem);
		    context->use_tmp_dh_file(info->TLSParams.dh);
		}
#endif

		prepareAccept();
	}

	void prepareAccept() {
		if(!SocketManager::getInstance()->work.get()) {
			return;
		}
#ifdef HAVE_OPENSSL
		if(serverInfo->secure()) {
			TLSSocketStream* s = new TLSSocketStream(io, *context);
			ManagedSocketPtr socket(new ManagedSocket(AsyncStreamPtr(s)));
			acceptor.async_accept(s->sock.lowest_layer(), std::bind(&SocketFactory::prepareHandshake, from_this(), std::placeholders::_1, socket));
		} else {
#endif
			SimpleSocketStream* s = new SimpleSocketStream(io);
			ManagedSocketPtr socket(new ManagedSocket(AsyncStreamPtr(s)));
			acceptor.async_accept(s->sock.lowest_layer(), std::bind(&SocketFactory::handleAccept, from_this(), std::placeholders::_1, socket));
#ifdef HAVE_OPENSSL
		}
#endif
	}

#ifdef HAVE_OPENSSL
	void prepareHandshake(const error_code& ec, const ManagedSocketPtr& socket) {
		if(!ec) {
			boost::intrusive_ptr<TLSSocketStream> tls = boost::static_pointer_cast<TLSSocketStream>(socket->sock);
			// By default, we linger for 30 seconds (this will happen when the stream
			// is deallocated without calling close first)
			tls->sock.lowest_layer().set_option(socket_base::linger(true, 30));
			try {
				socket->setIp(tls->sock.lowest_layer().remote_endpoint().address().to_string());
			} catch(const system_error&) { }
			tls->sock.async_handshake(ssl::stream_base::server, std::bind(&SocketFactory::completeAccept, from_this(), std::placeholders::_1, socket));
		}

		prepareAccept();
	}
#endif

	void handleAccept(const error_code& ec, const ManagedSocketPtr& socket) {
		if(!ec) {
			boost::intrusive_ptr<SimpleSocketStream> s = boost::static_pointer_cast<SimpleSocketStream>(socket->sock);
			// By default, we linger for 30 seconds (this will happen when the stream
			// is deallocated without calling close first)
			s->sock.lowest_layer().set_option(socket_base::linger(true, 30));
			try {
				socket->setIp(s->sock.lowest_layer().remote_endpoint().address().to_string());
			} catch(const system_error&) { }
		}

		completeAccept(ec, socket);

		prepareAccept();
	}

	void completeAccept(const error_code& ec, const ManagedSocketPtr& socket) {
		handler(socket);
		socket->completeAccept(ec);
	}

	void close() { acceptor.close(); }

	io_service& io;
	ip::tcp::acceptor acceptor;
	ServerInfoPtr serverInfo;
	SocketManager::IncomingHandler handler;

#ifdef HAVE_OPENSSL
	std::shared_ptr<boost::asio::ssl::context> context;
#endif

};

int SocketManager::run() {
	LOG(SocketManager::className, "Starting");

	for(std::vector<ServerInfoPtr>::iterator i = servers.begin(), iend = servers.end(); i != iend; ++i) {
		const ServerInfoPtr& si = *i;

		try {
			factories.push_back(SocketFactoryPtr(new SocketFactory(io, incomingHandler, si)));
		} catch(const system_error& se) {
			LOG(SocketManager::className, "Error while loading server on port " + Util::toString(si->port) +": " + se.what());
		}
	}

	io.run();

	io.reset();

	return 0;
}

void SocketManager::closeFactories() {
	for(std::vector<SocketFactoryPtr>::iterator i = factories.begin(), iend = factories.end(); i != iend; ++i) {
		(*i)->close();
	}
	factories.clear();
}

void SocketManager::addJob(const Callback& callback) throw() {
	io.post(callback);
}

SocketManager::Callback SocketManager::addJob(const long msec, const Callback& callback) {
	return addJob(boost::posix_time::milliseconds(msec), callback);
}

SocketManager::Callback SocketManager::addJob(const std::string& time, const Callback& callback) {
	return addJob(boost::posix_time::duration_from_string(time), callback);
}

SocketManager::Callback SocketManager::addJob(const boost::asio::deadline_timer::duration_type& duration, const Callback& callback) {
	timer_ptr timer(new timer_ptr::element_type(io, duration));
	timer->async_wait(std::bind(&SocketManager::handleWait, this, timer, std::placeholders::_1,
		new Callback(callback))); // create a separate callback on the heap to avoid shutdown crashes
	return std::bind(&SocketManager::cancelTimer, this, timer);
}

void SocketManager::handleWait(timer_ptr timer, const error_code& error, Callback* callback) {
	timer.reset();
	if(!error) {
		(*callback)();
	}
	delete callback;
}

void SocketManager::cancelTimer(timer_ptr timer) {
	if(timer.get()) {
		error_code ec;
		timer->cancel(ec);
	}
}

void SocketManager::startup() throw(ThreadException) {
	work.reset(new io_service::work(io));
	start();
}

void SocketManager::shutdown() {
	work.reset();
	addJob(std::bind(&SocketManager::closeFactories, this));
	io.stop();
	join();
}

void SocketManager::onLoad(const SimpleXML& xml) throw() {
	servers.clear();
}

}
