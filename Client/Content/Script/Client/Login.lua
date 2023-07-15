-----------------------------------------------------------------------------
-- Author: i0gan
-- Email : l418894113@gmail.com
-- Date  : 2023-01-01
-- Description: 登录模块
-----------------------------------------------------------------------------
require "Net.Http"

Login = Object({})

function Login:Create()

    self.cache = {
        account = "none",
        password = "",
        token = "",

        guid = "",
        limit_time = 0,
    
        world_id = 0,
        proxy_ip = "",
        proxy_port = 0,
        proxy_key = "",
        proxy_limit_time = 0,
    }

    self.is_login = false
    self.http = Http.New()
    self.url = Servers.login[1].url


end

-- 后面通过向服务器发包检测是否已经登录
function Login:CheckIsLogin()
    return self.is_login
end

function Login:LoginWithAccountPassword(account, password)

    self.cache.account = account
    self.cache.password = password

    local d = {
        type = 0,
        account = account,
        password = password,
        platform = 0,
        device = "windows",
        version = "1.0",
    }

    local r = self.http:PostJson(self.url .. "/login", d)
    if(r.code == 0) then
        self.cache.token = r.token
        self.cache.guid = r.guid
        -- 设置jwt
        self.http:SetJwt(r.guid, r.token)
        print("登录成功\n")

        self:GetWorldList()
    else
        print("登录失败\n")
    end

end

-- 获取区服列表
function Login:GetWorldList()
    local r = self.http:GetJson(self.url .. "/world/list")
    print_table(r)
    if(r.code == 0) then

        -- 选择第一个大区
        self:EnterWorld(r.world[1].id)
    end
    print("world_list", r)
end

function Login:EnterWorld(world_id)
    local r = self.http:PostJson(self.url .. "/world/enter", { world_id = world_id })
    print_table(r)
    if(r.code == 0) then
        self.cache.proxy_key = r.key
        self.cache.proxy_ip = r.ip
        self.cache.proxy_limit_time = r.limit_time
        self.cache.world_id = 100
        --self.guid = r.guid

        GameInstance:OnLogined(r.ip, r.port, r.guid, r.key)
    else
        print("进入大区失败\n")
    end
end