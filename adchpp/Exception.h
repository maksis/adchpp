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

#ifndef EXCEPTION_H
#define EXCEPTION_H

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

class Exception : public exception
{
public:
	Exception() { }
	Exception(const string& aError) throw() : error(aError) { dcdebug("Thrown: %s\n", error.c_str()); }
	virtual ~Exception() throw() { }
	const string& getError() const throw() { return error; }
	
	virtual const char* what() { return error.c_str(); }
protected:
	string error;
};

#ifdef _DEBUG

#define STANDARD_EXCEPTION(name) class name : public Exception { \
public:\
	name() throw() : Exception(#name) { } \
	name(const string& aError) throw() : Exception(#name ": " + aError) { } \
	virtual ~name() throw() { } \
}

#else // _DEBUG

#define STANDARD_EXCEPTION(name) class name : public Exception { \
public:\
	name() throw() : Exception() { } \
	name(const string& aError) throw() : Exception(aError) { } \
	virtual ~name() throw() { } \
}
#endif

#endif // EXCEPTION_H
