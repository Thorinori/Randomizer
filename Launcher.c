#include "./libs/UNIX/lua53/include/lua.h"
#include "./libs/UNIX/lua53/include/lualib.h"
#include "./libs/UNIX/lua53/include/lauxlib.h"
//#include "./libs/UNIX/iup/include/iuplua.h"
#include <stdlib.h>
#include <stdio.h>
//#include "Randomizer.loh"

void main(void)
{
  lua_State *L = luaL_newstate();

  luaL_openlibs(L);
  //iuplua_open(L);

  int err = luaL_dofile(L,"./Randomizer.lua");
  if(err == 1){
    printf("Error %s\n", lua_tostring(L,-1));
  }
  
}