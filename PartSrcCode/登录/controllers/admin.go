package controllers

import (
	"Blog/models"
	"Blog/util"
	"strings"
)

type AdminController struct{
	baseController
}


//后台用户登录
func (c *AdminController) Login(){

	if c.Ctx.Request.Method=="POST"{

		//从前台的请求中获取账号密码信息
		username:= c.GetString("username")
		password:= c.GetString("password")

		// 根据前面的信息从数据库中查出 username 的数据
		user := models.User{Username: username}
		c.o.Read(&user, "username")

		if user.Password == "" {
			c.History("账号不存在", "")
		}

		//判断登录信息是否正确
		if util.Md5(password)!=strings.Trim(user.Password," "){
			c.History("密码错误","")
		}

		//如果账号密码无误则更新admin信息
		user.LastIp= c.getClientIp()
		user.LoginCount=user.LoginCount+1
		if _,err:= c.o.Update(&user);err!=nil{
			c.History("登录异常","")
		}else{
			c.History("登录成功","/admin/main.html")
		}
		c.SetSession("user",user)
	}

	//注册登录模板
	c.TplName= c.controllerName+"/login.html"

}

//退出登录
func (c *AdminController) Logout() {
	c.DestroySession()
	c.History("退出登录","/admin/login.html")
}

func (c *AdminController) Main() {
	c.TplName = c.controllerName + "/main.tpl"
}
