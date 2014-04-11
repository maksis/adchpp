/*
 * Copyright (C) 2006-2014 Jacek Sieka, arnetheduck on gmail point com
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

#include "Hub.h"
#include "AdcCommand.h"
#include "version.h"

namespace adchpp {

Hub::Hub(ClientManager &cm) : Entity(cm, AdcCommand::HUB_SID) {
	setField("NI", "adchpp");
	setField("HI", "1");
	setField("DE", appName + ' ' + versionString);
	setField("AP", appName);
	setField("VE", versionString);
	setFlag(FLAG_HUB);
}

}
