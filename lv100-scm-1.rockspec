package = "LV-100"
version = "scm-1"
source = {
   url = "git+https://github.com/Eiyeron/LV-100.git"
}
description = {
   summary = "A Love2D library to make terminal-like stuff",
   detailed = [[A Love2D library intending to provide a way to make relatively easily fake terminals.]],
   homepage = "https://github.com/Eiyeron/LV-100",
   license = "MIT"
}
dependencies = {
    "love ~> 11"
}
build = {
   type = "builtin",
   modules = {
      lv100 = "terminal.lua"
   }
}
