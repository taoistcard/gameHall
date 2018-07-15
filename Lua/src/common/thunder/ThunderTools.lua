----------------------------------------------------------------------------------------------------------------------------------

string.split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end

--write file to disk
function write_content_to_file(path,content,mode)

    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        --print(content)
        local hr,err = file:write(content)
        if hr == nil then
            --print(err)
            return false
        end
        io.close(file)
        return true
    else
        --print("can't open file:"..path)
        return false
    end
end

function is_file_exists(path)
    return cc.FileUtils:getInstance():isFileExist(path)
end

function make_dir(path)
    --print(path)
    if lfs.chdir(path) then
        return
    end
    local rt = string.split(path,"/")

    local tmp = "/"
    for i = 1,#rt-1 do
        folder = rt[i]
        tmp = tmp..folder.."/"
        --rint(tmp)
        if lfs.chdir(tmp) == nil then
            --print("make")
            lfs.mkdir(tmp)
        end
    end
end

function clean_dir(path)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local fullpath = path..file
            --print(fullpath)
            local attr = lfs.attributes (fullpath)
            assert (type(attr) == "table")
            if attr.mode == "directory" then
                fullpath = fullpath.."/"
                clean_dir(fullpath)
                lfs.rmdir(fullpath)
            else
                --single file,do remove
                os.remove(fullpath)
            end
        end
    end
end


function write_file(path,content)
    make_dir(path)
    write_content_to_file(path,content)
end


function write_flist(path,flist)
    local content = "local flist ={\n" .. "\tcore="..flist.core..",\n\tpack="..flist.pack..",\n" .."version="..flist.version..",\n"
    content = content.."\tfiles={"
    for _,v in ipairs(flist.files) do
        if v ~= nil then
            local fileDesc = "\n\t\t{ file=\""..v.file.."\", md5=\""..v.md5.."\", size="..v.size.."},"
            content = content..fileDesc
        end
    end
    content = content.."\n\t}\n}\nreturn flist"
    write_file(path, content)
end

function lua_do_string(str)
    local fn = loadstring(str)

    if fn ~= nil then
        retval = fn()
        return retval
    end

    return nil;
end


function write_file(path,content)
    make_dir(path)
    write_content_to_file(path,content)
end
----------------------------------------------------------------------------------------------------------------------------------
