--[[
Title: Github api
Author: leio
Date: 2017/11/21
Desc: 
------------------------------------------------------------------
local GithubService = NPL.load("NplAuthorization/github/GithubService.lua");
------------------------------------------------------------------
]]
local GithubService = commonlib.inherit(nil, NPL.export());

NPL.load("(gl)script/ide/Encoding.lua");
NPL.load("(gl)script/ide/System/Encoding/base64.lua");
local Encoding = commonlib.gettable("System.Encoding");

function GithubService:ctor()
    self.api = nil;
    self.token  = nil;
    return self;
end
function GithubService:onInit(token,api,branch)
    self.token  = token;
    self.api = api or "https://api.github.com";
    self.branch = branch or "master";
    self.headers = {
        ["Accept"] = "application/vnd.github.full+json",
        ["User-Agent"] = "Npl",
        --["Authorization"] = "Bearer " .. token, 
    }
    return self;
end

--https://developer.github.com/v3/users/#get-the-authenticated-user
function GithubService:getProfile(callback)
    local url = string.format("%s/user?access_token=%s",self.api,self.token);
    LOG.std(nil,"debug","GithubService:getProfile",url)
    System.os.GetUrl({
        url = url,
        json = true,
        headers = self.headers,
    }, function(err, msg)
        LOG.std(nil,"debug","GithubService:getProfile status",err)
        LOG.std(nil,"debug","GithubService:getProfile msg",msg)
        if(callback)then
            callback(err, msg);
        end
    end);
end
--https://developer.github.com/v3/repos/contents/#get-contents
function GithubService:getFile(owner,repo,path,callback)
    if(not owner or not repo or not path)then return end
    local url;
    if(not self.token or self.token == "")then
        url = string.format("%s/repos/%s/%s/contents/%s?ref=%s",self.api,owner,repo,path,self.branch);
    else
        url = string.format("%s/repos/%s/%s/contents/%s?ref=%s&access_token=%s",self.api,owner,repo,path,self.branch,self.token);
    end
    LOG.std(nil,"debug","GithubService:getFile",url)
    System.os.GetUrl({
        url = url,
        json = true,
        headers = self.headers,
    }, function(err, msg)
        LOG.std(nil,"debug","GithubService:getFile status",err)
        LOG.std(nil,"debug","GithubService:getFile msg",msg)
        if(callback)then
            callback(err, msg);
        end
    end);
end
--https://developer.github.com/v3/repos/contents/#get-contents
function GithubService:getContent(owner,repo,path,callback)
    self:getFile(owner,repo,path,function(err, msg)
        if(err == 200)then
            if(msg and msg.data)then
                local data = msg.data;
                local content = data.content;
                local name = data.name;
                local path = data.path;
                local download_url = data.download_url;
                LOG.std(nil,"debug","GithubService:getContent values",{name = name, path = path, download_url = download_url, })
                System.os.GetUrl({ url = download_url },function(err, msg)
                    LOG.std(nil,"debug","GithubService:getContent status",err)
                    LOG.std(nil,"debug","GithubService:getContent msg",msg)
                    if(callback)then
                        callback(err, msg);
                    end
                end);
            end
        else
            if(callback)then
                callback(err, msg);
            end
        end
    end)
end
--https://developer.github.com/v3/repos/contents/#create-a-file
function GithubService:createFile(owner,repo,path,content,callback)
    if(not owner or not repo or not path)then return end
    local url = string.format("%s/repos/%s/%s/contents/%s?access_token=%s",self.api,owner,repo,path,self.token);
    LOG.std(nil,"debug","GithubService:createFile",url)
    System.os.GetUrl({
        method = "PUT",
        url = url,
        json = true,
        headers = self.headers,
        form = {
            ["message"] = "create file " .. path,
            ["content"] = Encoding.base64(content),
            ["branch"] = self.branch,
        }
    }, function(err, msg)
        LOG.std(nil,"debug","GithubService:createFile status",err)
        LOG.std(nil,"debug","GithubService:createFile msg",msg)
        if(callback)then
            callback(err, msg);
        end
    end)
end
--https://developer.github.com/v3/repos/contents/#update-a-file
function GithubService:updateFile(owner,repo,path,content,callback)
    if(not owner or not repo or not path)then return end
    self:getFile(owner,repo,path,function(err, msg)
        if(err == 200)then
            if(msg and msg.data)then
                local data = msg.data;
                local sha = data.sha;
                local url = string.format("%s/repos/%s/%s/contents/%s?access_token=%s",self.api,owner,repo,path,self.token);
                LOG.std(nil,"debug","GithubService:updateFile",url)
                System.os.GetUrl({
                    method = "PUT",
                    url = url,
                    json = true,
                    headers = self.headers,
                    form = {
                        ["message"] = "update file " .. path,
                        ["content"] = Encoding.base64(content),
                        ["branch"] = self.branch,
                        ["sha"] = sha,
                    }
                }, function(err, msg)
                    LOG.std(nil,"debug","GithubService:updateFile status",err)
                    LOG.std(nil,"debug","GithubService:updateFile msg",msg)
                    if(callback)then
                        callback(err, msg);
                    end
                end)
            end
        else
            if(callback)then
                callback(err, msg);
            end
        end
    end)
end
--https://developer.github.com/v3/repos/contents/#delete-a-file
function GithubService:deleteFile(owner,repo,path,callback)
    self:getFile(owner,repo,path,function(err, msg)
        if(err == 200)then
            if(msg and msg.data)then
                local data = msg.data;
                local sha = data.sha;
                local url = string.format("%s/repos/%s/%s/contents/%s?access_token=%s",self.api,owner,repo,path,self.token);
                LOG.std(nil,"debug","GithubService:deleteFile",url)
                System.os.GetUrl({
                    method = "DELETE",
                    url = url,
                    json = true,
                    headers = self.headers,
                    form = {
                        ["message"] = "delete file " .. path,
                        ["branch"] = self.branch,
                        ["sha"] = sha,
                    }
                }, function(err, msg)
                    LOG.std(nil,"debug","GithubService:deleteFile status",err)
                    LOG.std(nil,"debug","GithubService:deleteFile msg",msg)
                    if(callback)then
                        callback(err, msg);
                    end
                end)
            end
        else
            if(callback)then
                callback(err, msg);
            end
        end
    end)
end
--https://developer.github.com/v3/git/trees/#get-a-tree-recursively
function GithubService:getRootTree(owner,repo,recursive,callback)
    if(not owner or not repo)then return end
    local url;
    if(recursive and tonumber(recursive) == 1)then
        if(not self.token or self.token == "")then
            url = string.format("%s/repos/%s/%s/git/trees/%s?recursive=1",self.api,owner,repo,self.branch);
        else
            url = string.format("%s/repos/%s/%s/git/trees/%s?access_token=%s&recursive=1",self.api,owner,repo,self.branch,self.token);
        end
    else
        if(not self.token or self.token == "")then
            url = string.format("%s/repos/%s/%s/git/trees/%s",self.api,owner,repo,self.branch);
        else
            url = string.format("%s/repos/%s/%s/git/trees/%s?access_token=%s",self.api,owner,repo,self.branch,self.token);
        end
    end
    LOG.std(nil,"debug","GithubService:getTree",url)
     System.os.GetUrl({
        url = url,
        json = true,
        headers = self.headers,
    }, function(err, msg, data)
        LOG.std(nil,"debug","GithubService:getRootTree status",err)
        LOG.std(nil,"debug","GithubService:getRootTree msg",msg)
        if(callback)then
            callback(err, msg);
        end
    end);
end
--https://developer.github.com/v3/repos/hooks/#list-hooks
function GithubService:listHooks(owner,repo,callback)
    if(not owner or not repo)then return end
    local url = string.format("%s/repos/%s/%s/hooks?access_token=%s",self.api,owner,repo,self.token);
    LOG.std(nil,"debug","GithubService:listHooks",url)
     System.os.GetUrl({
        url = url,
        json = true,
        headers = self.headers,
    }, function(err, msg)
        LOG.std(nil,"debug","GithubService:listHooks status",err)
        LOG.std(nil,"debug","GithubService:listHooks msg",msg)
        if(callback)then
            callback(err, msg);
        end
    end);
end
--https://developer.github.com/v3/repos/hooks/#create-a-hook
function GithubService:createHook(owner,repo,callback_url,callback)
    if(not owner or not repo or not callback_url)then return end
    local url = string.format("%s/repos/%s/%s/hooks?access_token=%s",self.api,owner,repo,self.token);
    LOG.std(nil,"debug","GithubService:createHook",url)
     System.os.GetUrl({
        method = "POST",
        url = url,
        json = true,
        headers = self.headers,
        form = {
            name = "web",
            active = true,
            events = { "push" },
            config = { url  = callback_url, content_type = "json", },
        },
    }, function(err, msg)
        LOG.std(nil,"debug","GithubService:createHook status",err)
        LOG.std(nil,"debug","GithubService:createHook msg",msg)
        if(callback)then
            callback(err, msg);
        end
    end);
end
--https://developer.github.com/v3/repos/#list-your-repositories
function GithubService:getRepos(visibility,affiliation,sort,direction,callback)
    visibility = visibility or "public";
    affiliation = affiliation or "owner";
    sort = sort or "created";
    direction = direction or "asc";
    local url = string.format("%s/user/repos?visibility=%s&affiliation=%s&sort=%s&direction=%s&access_token=%s",self.api,visibility,affiliation,sort,direction,self.token);
    LOG.std(nil,"debug","GithubService:getRepos",url)
     System.os.GetUrl({
        url = url,
        json = true,
        headers = self.headers,
    }, function(err, msg)
        LOG.std(nil,"debug","GithubService:getRepos status",err)
        LOG.std(nil,"debug","GithubService:getRepos msg",msg)
        if(callback)then
            callback(err, msg);
        end
    end);
end
--https://developer.github.com/v3/repos/#create
function GithubService:createRepos(name,callback)
    if(not name)then return end
    local url = string.format("%s/user/repos?access_token=%s",self.api,self.token);
    LOG.std(nil,"debug","GithubService:createRepos",url)
     System.os.GetUrl({
        method = "POST",
        url = url,
        json = true,
        headers = self.headers,
        form = {
            name = name,
            description = name,
            private = false,
        },
    }, function(err, msg)
        LOG.std(nil,"debug","GithubService:createRepos status",err)
        LOG.std(nil,"debug","GithubService:createRepos msg",msg)
        if(callback)then
            callback(err, msg);
        end
    end);
end
--https://developer.github.com/v3/repos/#delete-a-repository
function GithubService:deleteRepos(owner,name,callback)
    if(not owner or not name)then return end
    local url = string.format("%s/repos/%s/%s?access_token=%s",self.api,owner,name,self.token);
    LOG.std(nil,"debug","GithubService:deleteRepos",url)
     System.os.GetUrl({
        method = "DELETE",
        url = url,
        json = true,
        headers = self.headers,
    }, function(err, msg)
        LOG.std(nil,"debug","GithubService:deleteRepos status",err)
        LOG.std(nil,"debug","GithubService:deleteRepos msg",msg)
        if(callback)then
            callback(err, msg);
        end
    end);
end
--https://developer.github.com/v3/repos/#get
function GithubService:getRepoInfo(owner,name,callback)
    if(not owner or not name)then return end
    local url = string.format("%s/repos/%s/%s?access_token=%s",self.api,owner,name,self.token);
    LOG.std(nil,"debug","GithubService:getRepoInfo",url)
     System.os.GetUrl({
        url = url,
        json = true,
        headers = self.headers,
    }, function(err, msg)
        LOG.std(nil,"debug","GithubService:getRepoInfo status",err)
        LOG.std(nil,"debug","GithubService:getRepoInfo msg",msg)
        if(callback)then
            callback(err, msg);
        end
    end);
end
