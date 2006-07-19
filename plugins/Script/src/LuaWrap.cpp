/* 
 * Copyright (C) 2006 Jacek Sieka, arnetheduck on gmail point com
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

#include "stdinc.h"

#include "LuaWrap.h"
#include "LuaCommon.h"

#include <adchpp/PluginManager.h>
#include <adchpp/ClientManager.h>

#include <adchpp/Client.h>

using namespace luabind;

const char LuaWrap::module_name[7] = "adchpp";

namespace {
	
PluginManager* getPM() {
	return PluginManager::getInstance();
}
typedef pointer_wrapper<PluginManager> LuaPluginManager;

}

LuaWrap::~LuaWrap() { }

void LuaWrap::wrap_pm(lua_State* L) {
	module(L, module_name)
	[
		class_<PluginManager, LuaPluginManager>("PluginManager"),
		def("getPM", &getPM)
	];
}

void LuaWrap::wrap(lua_State* L) {
	open(L);
	
	wrap_aux(L);
	wrap_client(L);
	wrap_pm(L);
	wrap_cm(L);
}
