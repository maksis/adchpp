%{

#include <adchpp/adchpp.h>
#include <adchpp/common.h>

#include <adchpp/Signal.h>
#include <adchpp/Client.h>
#include <adchpp/ClientManager.h>
#include <adchpp/Exception.h>

using namespace adchpp;

%}

%include "std_string.i"
%include "std_vector.i"
%include "std_except.i"

%inline%{
void startup() {
	adchpp::startup(0);
}
void shutdown() {
	adchpp::shutdown(0);
}
%}

%nodefaultctor;

namespace adchpp {
	class Client;
}

%template(TClientList) std::vector<adchpp::Client*>;
%template(TStringList) std::vector<std::string>;

typedef std::vector<std::string> StringList;
%inline%{
typedef std::vector<adchpp::Client*> ClientList;
%}

namespace adchpp {

void initConfig(const std::string& configPath);

template<typename F>
struct Signal {

	template<typename T0>
	void operator()(T0& t0);
	template<typename T0, typename T1>
	void operator()(T0& t0, T1& t1);
	
	template<typename T0, typename T1, typename T2>
	void operator()(const T0& t0, const T1& t1, const T2& t2);

	template<typename T0, typename T1, typename T2>
	void operator()(const T0& t0, T1& t1, T2& t2);
	
	template<typename T0, typename T1, typename T2>
	void operator()(T0& t0, T1& t1, T2& t2);
	
	template<typename T>
	void connect(T f);
	
	~Signal() { }
};

template<typename Sig>
struct ManagedConnection {
	ManagedConnection();
	ManagedConnection(const typename Sig::Connection& conn);
	
	~ManagedConnection();
	typename Sig::Connection connection;
};

class Exception : public std::exception
{
public:
	Exception();
	Exception(const string& aError) throw();
	virtual ~Exception() throw();
	const string& getError() const throw();
	
	virtual const char* what();
};

class CID {
public:
	enum { SIZE = 192 / 8 };
	enum { BASE32_SIZE = 39 };

	CID();
	explicit CID(const uint8_t* data);
	explicit CID(const string& base32);

	bool operator==(const CID& rhs) const;
	bool operator<(const CID& rhs) const;

	string toBase32() const;
	//string& toBase32(string& tmp) const;

	size_t toHash() const;
	const uint8_t* data() const;

	bool isZero() const;
	static CID generate();

};

class ParseException : public Exception {
public:
	ParseException() throw();
	ParseException(const string&) throw();
};

class AdcCommand {
public:
/*	template<uint32_t T>
	struct Type {
		enum { CMD = T };
	};
*/
	enum Error {
		ERROR_GENERIC = 0,
		ERROR_HUB_GENERIC = 10,
		ERROR_HUB_FULL = 11,
		ERROR_HUB_DISABLED = 12,
		ERROR_LOGIN_GENERIC = 20,
		ERROR_NICK_INVALID = 21,
		ERROR_NICK_TAKEN = 22,
		ERROR_BAD_PASSWORD = 23,
		ERROR_CID_TAKEN = 24,
		ERROR_COMMAND_ACCESS = 25,
		ERROR_REGGED_ONLY = 26,
		ERROR_INVALID_PID = 27,
		ERROR_BANNED_GENERIC = 30,
		ERROR_PERM_BANNED = 31,
		ERROR_TEMP_BANNED = 32,
		ERROR_PROTOCOL_GENERIC = 40,
		ERROR_PROTOCOL_UNSUPPORTED = 41,
		ERROR_INF_MISSING = 42,
		ERROR_BAD_STATE = 43,
		ERROR_FEATURE_MISSING = 44,
		ERROR_BAD_IP = 45,
		ERROR_TRANSFER_GENERIC = 50,
		ERROR_FILE_NOT_AVAILABLE = 51,
		ERROR_FILE_PART_NOT_AVAILABLE = 52,
		ERROR_SLOTS_FULL = 53
	};

	enum Severity {
		SEV_SUCCESS = 0,
		SEV_RECOVERABLE = 1,
		SEV_FATAL = 2
	};

	static const char TYPE_BROADCAST = 'B';
	static const char TYPE_DIRECT = 'D';
	static const char TYPE_ECHO = 'E';
	static const char TYPE_FEATURE = 'F';
	static const char TYPE_INFO = 'I';
	static const char TYPE_HUB = 'H';

	// Known commands...
#define C(n, a, b, c) static const unsigned int CMD_##n = (((uint32_t)a) | (((uint32_t)b)<<8) | (((uint32_t)c)<<16)); 
	// Base commands
	C(SUP, 'S','U','P');
	C(STA, 'S','T','A');
	C(INF, 'I','N','F');
	C(MSG, 'M','S','G');
	C(SCH, 'S','C','H');
	C(RES, 'R','E','S');
	C(CTM, 'C','T','M');
	C(RCM, 'R','C','M');
	C(GPA, 'G','P','A');
	C(PAS, 'P','A','S');
	C(QUI, 'Q','U','I');
	C(DSC, 'D','S','C');
	C(GET, 'G','E','T');
	C(GFI, 'G','F','I');
	C(SND, 'S','N','D');
	C(SID, 'S','I','D');
	// Extensions
	C(CMD, 'C','M','D');
#undef C

	enum { HUB_SID = 0x41414141 };

	AdcCommand();
	explicit AdcCommand(Severity sev, Error err, const string& desc, char aType = TYPE_INFO);
	explicit AdcCommand(uint32_t cmd, char aType = TYPE_INFO, uint32_t aFrom = HUB_SID);
	explicit AdcCommand(const string& aLine) throw(ParseException);
	AdcCommand(const AdcCommand& rhs);

	void parse(const string& aLine) throw(ParseException);
	uint32_t getCommand() const;
	char getType() const;

	StringList& getParameters();
	//const StringList& getParameters() const;

	const string& toString() const;
	void resetString();

	AdcCommand& addParam(const string& name, const string& value);
	AdcCommand& addParam(const string& str);
	const string& getParam(size_t n) const;

	bool getParam(const char* name, size_t start, string& ret) const;
	bool delParam(const char* name, size_t start);
	
	bool hasFlag(const char* name, size_t start) const;
	static uint16_t toCode(const char* x);

	bool operator==(uint32_t aCmd) const;

	static string escape(const string& s);

	uint32_t getTo() const;
	void setTo(uint32_t aTo);
	uint32_t getFrom() const;
	void setFrom(uint32_t aFrom);

	static uint32_t toSID(const string& aSID);
	static string fromSID(const uint32_t aSID);
	static void appendSID(string& str, uint32_t aSID);
};

class Client {
public:
	enum State {
		STATE_PROTOCOL,
		STATE_IDENTIFY,
		STATE_VERIFY,
		STATE_NORMAL,
		STATE_DATA
	};

	enum {
		FLAG_BOT = 0x01,
		FLAG_OP = 0x02,				
		FLAG_PASSWORD = 0x04,
		FLAG_HIDDEN = 0x08,
		FLAG_HUB = 0x10,
		FLAG_EXT_AWAY = 0x20,
		FLAG_OK_COUNT = 0x80,
		FLAG_OK_IP = 0x100
	};

	//static Client* create(uint32_t sid) throw();
	//DLL void deleteThis() throw();

	const StringList& getSupportList() const throw();
	bool supports(const string& feat) const throw();

	//void send(const char* command, size_t len) throw();
	//void send(const AdcCommand& cmd) throw();
	void send(const string& command) throw();
	void send(const char* command) throw();

	void disconnect() throw();
	//ManagedSocket* getSocket() throw() { return socket; }
	//const ManagedSocket* getSocket() const throw() { return socket; }
	const string& getIp() const throw();

	//void setSocket(ManagedSocket* aSocket) throw();

	//void setDataMode(boost::function<void (const uint8_t*, size_t)> handler, int64_t aBytes) { dataHandler = handler; dataBytes = aBytes; }

	/** Add any flags that have been updated to the AdcCommand (type etc is not set) */
	bool getChangedFields(AdcCommand& cmd);
	bool getAllFields(AdcCommand& cmd);

	void resetChanged() { changed.clear(); }

	const string& getField(const char* name) const throw();
	void setField(const char* name, const string& value) throw();

	void updateFields(const AdcCommand& cmd) throw();
	void updateSupports(const AdcCommand& cmd) throw();

	bool isUdpActive();
	bool isTcpActive();

	bool isFlooding(time_t addSeconds);
	
	//void* setPSD(int id, void* data) throw();
	//void* getPSD(int id) throw();
	
	const CID& getCID() const { return cid; }
	void setCID(const CID& cid_) { cid = cid_; }
	uint32_t getSID() const { return sid; }
	State getState() const { return state; }
	void setState(State state_) { state = state_; }

	//Client(uint32_t aSID) throw();
	//virtual ~Client() throw() { }
};

class ClientManager 
{
public:
	enum SignalCommandOverride {
		DONT_DISPATCH = 1 << 0,
		DONT_SEND = 1 << 1
	};
	
	//typedef HASH_MAP<uint32_t, Client*> ClientMap;
	//typedef ClientMap::iterator ClientIter;
	
	void addSupports(const string& str) throw();
	void removeSupports(const string& str) throw();

	void updateCache() throw();
	
	uint32_t getSID(const string& nick) const throw();
	uint32_t getSID(const CID& cid) const throw();
	
	Client* getClient(const uint32_t& aSid) throw();
	//ClientMap& getClients() throw() { return clients; }
	%extend{
	ClientList getClients() throw() {
		ClientList ret;
		for(ClientManager::ClientMap::iterator i = self->getClients().begin(); i != self->getClients().end(); ++i) {
			ret.push_back(i->second);
		}
		return ret;
	}
	}
	
	void send(const AdcCommand& cmd, bool lowPrio = false) throw();
	void sendToAll(const AdcCommand& cmd) throw();
	void sendTo(const AdcCommand& cmd, const uint32_t& to) throw();

	bool checkFlooding(Client& c, const AdcCommand&) throw();
	
	void enterIdentify(Client& c, bool sendData) throw();

	vector<uint8_t> enterVerify(Client& c, bool sendData) throw();

	bool enterNormal(Client& c, bool sendData, bool sendOwnInf) throw();
	bool verifySUP(Client& c, AdcCommand& cmd) throw();
	bool verifyINF(Client& c, AdcCommand& cmd) throw();
	bool verifyNick(Client& c, const AdcCommand& cmd) throw();
	bool verifyPassword(Client& c, const string& password, const vector<uint8_t>& salt, const string& suppliedHash);
	bool verifyIp(Client& c, AdcCommand& cmd) throw();
	bool verifyCID(Client& c, AdcCommand& cmd) throw();
	bool verifyUsers(Client& c) throw();

	//void incomingConnection(ManagedSocket* ms) throw();
	
	//void startup() throw() { updateCache(); }
	//void shutdown();
	
	typedef Signal<void (Client&)> SignalConnected;
	typedef Signal<void (Client&, AdcCommand&, int&)> SignalReceive;
	typedef Signal<void (Client&, const string&)> SignalBadLine;
	typedef Signal<void (Client&, AdcCommand&, int&)> SignalSend;
	typedef Signal<void (Client&, int)> SignalState;
	typedef Signal<void (Client&)> SignalDisconnected;

	SignalConnected& signalConnected() { return signalConnected_; }
	SignalReceive& signalReceive() { return signalReceive_; }
	SignalBadLine& signalBadLine() { return signalBadLine_; }
	SignalSend& signalSend() { return signalSend_; }
	SignalState& signalState() { return signalState_; }
	SignalDisconnected& signalDisconnected() { return signalDisconnected_; }

	//virtual ~ClientManager() throw() { }
};


%template(SignalClient) Signal<void (Client&)>;
%extend Signal<void (Client&)> {
	%template(__call__) operator()<Client>;
	//void xconn(const boost::function<void (Client&)> c) { self->connect(c); }
	%template(connect) connect<boost::function<void (Client&)> >;
}
}

%inline%{
namespace adchpp {
	ClientManager* getCM() { return ClientManager::getInstance(); }
}
%}