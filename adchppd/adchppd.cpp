/*
 * Copyright (C) 2006-2009 Jacek Sieka, arnetheduck on gmail point com
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

#include <adchpp/adchpp.h>
#include <adchpp/common.h>

#include "adchppd.h"

#include <adchpp/Util.h>
#include <adchpp/ClientManager.h>
#include <adchpp/SocketManager.h>
#include <adchpp/PluginManager.h>
#include <adchpp/Entity.h>
#include <adchpp/File.h>
#include <adchpp/SimpleXML.h>

using namespace adchpp;
using namespace std;

void loadXML(const string& aFileName)
{
	try {
		SimpleXML xml;

		xml.fromXML(File(aFileName, File::READ, File::OPEN).read());

		xml.resetCurrentChild();

		xml.stepIn();

		while(xml.findChild(Util::emptyString)) {
			if(xml.getChildName() == "Settings") {
				xml.stepIn();

				while(xml.findChild(Util::emptyString)) {

					printf("Processing %s\n", xml.getChildName().c_str());
					if(xml.getChildName() == "HubName") {
						ClientManager::getInstance()->getEntity(AdcCommand::HUB_SID)->setField("NI", xml.getChildData());
					} else if(xml.getChildName() == "Description") {
						ClientManager::getInstance()->getEntity(AdcCommand::HUB_SID)->setField("DE", xml.getChildData());
					} else if(xml.getChildName() == "Log") {
					}
				}

				xml.stepOut();
			} else if(xml.getChildName() == "Servers") {
				xml.stepIn();

				ServerInfoList servers;

				while(xml.findChild("Server")) {
					ServerInfoPtr server;

					bool secure;
					if(xml.getBoolChildAttrib("TLS")) {
						TLSServerInfoPtr p(new TLSServerInfo);
						p->cert = xml.getChildAttrib("Certificate");
						p->pkey = xml.getChildAttrib("PrivateKey");
						p->trustedPath = xml.getChildAttrib("TrustedPath");
						p->dh = xml.getChildAttrib("DHParams");

						server = p;
						secure = true;
					} else {
						server.reset(new ServerInfo);
						secure = false;
					}

					server->port = Util::toInt(xml.getChildAttrib("Port", Util::emptyString));
					printf("Listening on port %d (secure: %s)\n", server->port, secure ? "yes" : "no");
					servers.push_back(server);
				}

				SocketManager::getInstance()->setServers(servers);

				xml.stepOut();
			} else if(xml.getChildName() == "Plugins") {
				PluginManager::getInstance()->setPluginPath(xml.getChildAttrib("Path"));
				xml.stepIn();
				StringList plugins;
				while(xml.findChild("Plugin")) {
					plugins.push_back(xml.getChildData());
				}
				PluginManager::getInstance()->setPluginList(plugins);
				xml.stepOut();
			}
		}

		xml.stepOut();
	} catch(const Exception& e) {
		printf("Unable to load adchpp.xml, using defaults: %s\n", e.getError().c_str());
	}
}
