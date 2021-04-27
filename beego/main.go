package main

import (
	"beego/models"
	_"beego/routers"
	"github.com/astaxie/beego"
)

func main() {
	models.Init()
	beego.Run()
}

// go get github.com/astaxie/beego/orm@v1.12.3
