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

//配置后台
func (c *AdminController) Config(){
	//读取后台信息，后台信息由ID,name,value三列组成
	//key-value对可以是QQ, URL, 时区等内容
	var result []*models.Config
	c.o.QueryTable(new(models.Config).TableName()).All(&result)

	//建两个map
	//option用于向模板中传递参数，和数据库中的表示方法一样：name-value，所以是string-string
	//mp则用与检查，表示方法是：name-Config{}结构体
	options := make(map[string]string)
	mp := make(map[string]*models.Config)
	for _, v := range result {
		options[v.Name] = v.Value
		mp[v.Name] = v //v是一个Config结构体
	}
	if c.Ctx.Request.Method == "POST" {
		keys := []string{"url", "title", "keywords", "description", "email", "start", "qq"}
		for _, key := range keys {
			val := c.GetString(key) //从我们post的请求中读取参数
			//先检查一下数据库中有没有我们读取到的参数
			if _, ok := mp[key]; !ok {  //没有
				c.o.Insert(&models.Config{Name: key, Value: val})
			} else { //如果已经有了，则需要更新
				opt := mp[key]
				if _, err := c.o.Update(&models.Config{Id: opt.Id, Name: opt.Name, Value: val/*此处使用POST数据*/}); err != nil {
					panic(err)
				}
			}
		}
		c.History("设置数据成功", "")
	}
	c.Data["config"] = options
	c.TplName = c.controllerName + "/config.html"
}

func (c *AdminController) Main() { //不要忘了注册后台主页面
	c.TplName = c.controllerName + "/main.tpl"
}
