local reload_time = os.time() + 3
function onUpdate()
	if isKeyDown(17) and isKeyDown(82) and (reload_time + 3 <= os.time()) then
		reload_time = os.time()
		local files = listFiles(getWorkingDirectory())
		for _, file in ipairs(files) do
			if file:find('(.+).lua') and file ~= 'reload_all.lua' then
				local fileName = file:match('(.+).lua')
				unloadScript(fileName);
				loadScript(file);
				print('[Скрипт '..file..' был успешно перезагружен.]')
			end
		end
	end
end

function listFiles(directory)
    local files = {}
    local p = io.popen('dir "' .. directory .. '" /b')
    for filename in p:lines() do
        table.insert(files, filename)
    end
    p:close()
    return files
end
