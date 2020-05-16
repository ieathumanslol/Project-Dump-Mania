sflink = "https://raw.githubusercontent.com/superyor/SuFramework/master/SuFramework.lua";
script = file.Open("Modules\\Superyu\\SuFramework.lua", "w");
newScript = http.Get(sflink)
script:Write(newScript);
script:Close()
sscript = http.Get("https://raw.githubusercontent.com/ieathumanslol/Project-Dump-Mania/master/ProjectDumpmaniaob.lua")
name = GetScriptName()
f = file.Open( name, "w")
f:Write(sscript);
f:Close()
LoadScript(name)