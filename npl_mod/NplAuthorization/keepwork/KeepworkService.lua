--[[
Title: Keepwork api
Author: leio
Date: 2017/11/28
Desc: 
------------------------------------------------------------------
local KeepworkService = NPL.load("NplAuthorization/keepwork/KeepworkService.lua");
------------------------------------------------------------------
]]
local KeepworkService = commonlib.inherit(nil, NPL.export());

function KeepworkService:ctor()
    self.api = nil;
    self.token  = nil;
    return self;
end
function KeepworkService:onInit(token,api,branch)
    self.token  = token;
    self.api = api or "http://keepwork.com/api";
    self.branch = branch or "master";
    self.headers = {
        ["Accept"] = "application/vnd.github.full+json",
        ["User-Agent"] = "Npl",
        ["Authorization"] = "Bearer " .. token, 
    }
    return self;
end
function KeepworkService:getProfile(callback)
    local url = string.format("%s/wiki/models/user/getProfile",self.api);
    LOG.std(nil,"debug","KeepworkService:getProfile",url)
    System.os.GetUrl({
        url = url,
        json = true,
        headers = self.headers,
    }, function(err, msg)
        LOG.std(nil,"debug","KeepworkService:getProfile status",err)
        LOG.std(nil,"debug","KeepworkService:getProfile msg",msg)
        if(callback)then
            callback(err, msg);
        end
    end);
end