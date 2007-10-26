# $Id: gch.py 320 2006-07-18 15:58:09Z tim $
# 
# SCons builder for gcc's precompiled headers
# Copyright (C) 2006  Tim Blechmann
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.

# $Revision: 320 $
# $LastChangedRevision: 320 $
# $LastChangedDate: 2006-07-18 17:58:09 +0200 (tis, 18 jul 2006) $
# $LastChangedBy: tim $

import SCons.Action
import SCons.Builder
import SCons.Scanner.C
import SCons.Util
import SCons

GchAction = SCons.Action.Action('$GCHCOM')
GchShAction = SCons.Action.Action('$GCHSHCOM')

def gen_suffix(env, sources):
    return sources[0].get_suffix() + env['GCHSUFFIX']

if SCons.__version__ == "0.96.1":
    scanner = SCons.Scanner.C.CScan()
else:
    scanner = SCons.Scanner.C.CScanner()

GchShBuilder = SCons.Builder.Builder(action = GchShAction,
                                     source_scanner = scanner,
                                     suffix = gen_suffix)

GchBuilder = SCons.Builder.Builder(action = GchAction,
                                   source_scanner = scanner,
                                   suffix = gen_suffix)

def static_pch_emitter(target,source,env):
    SCons.Defaults.StaticObjectEmitter( target, source, env )
	
    path = scanner.path(env)
    deps = scanner(source[0], env, path)
    if env.has_key('Gch') and env['Gch']:
        if env['Gch'].path[:-4] in [x.path for x in deps]:
            env.Depends(target, env['Gch'])

    return (target, source)

def shared_pch_emitter(target,source,env):
    SCons.Defaults.SharedObjectEmitter( target, source, env )

    path = scanner.path(env)
    deps = scanner(source[0], env, path)
    if env.has_key('GchSh') and env['GchSh']:
        if env['GchSh'].path[:-4] in [x.path for x in deps]:
            env.Depends(target, env['GchSh'])
    return (target, source)

def generate(env):
    """
    Add builders and construction variables for the DistTar builder.
    """
    env.Append(BUILDERS = {
        'gch': env.Builder(
        action = GchAction,
        target_factory = env.fs.File,
        ),
        'gchsh': env.Builder(
        action = GchShAction,
        target_factory = env.fs.File,
        ),
        })

    try:
        bld = env['BUILDERS']['Gch']
        bldsh = env['BUILDERS']['GchSh']
    except KeyError:
        bld = GchBuilder
        bldsh = GchShBuilder
        env['BUILDERS']['Gch'] = bld
        env['BUILDERS']['GchSh'] = bldsh

    env['GCHCOM']     = '$CXX $CXXFLAGS $CPPFLAGS $_CPPDEFFLAGS $_CPPINCFLAGS -o $TARGET -x c++-header -c $SOURCE'
    env['GCHSHCOM']   = '$CXX $SHCXXFLAGS $CPPFLAGS $_CPPDEFFLAGS $_CPPINCFLAGS -o $TARGET -x c++-header -c $SOURCE'
    env['GCHSUFFIX']  = '.gch'

    for suffix in SCons.Util.Split('.c .C .cc .cxx .cpp .c++'):
        env['BUILDERS']['StaticObject'].add_emitter( suffix, static_pch_emitter )
        env['BUILDERS']['SharedObject'].add_emitter( suffix, shared_pch_emitter )


def exists(env):
    return env.Detect('g++')
