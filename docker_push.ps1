# 設定權限
# VSCode -> 內容 -> 進階 -> 以系統管理員身分執行
# Get-ExecutionPolicy -List
# Set-ExecutionPolicy UnRestricted

# 執行
# ./docker_push.ps1 Tab鍵
param(
    [ValidateSet('beego', 'delete')]
    [string]$Container
)
"[Step_1] choose container -> $Container"
switch ($Container) {
    'beego' {
        $Directory = 'golang'

        $main = 'beego/main.go'

        $Directory_Container = '/go/src'
        $Directory_conf = 'beego/conf'
        $Directory_controllers = 'beego/controllers'
        $Directory_models = 'beego/models'
        $Directory_routers = 'beego/routers'
        $Directory_static = 'beego/static'
        $Directory_views = 'beego/views'

        $Container = 'beego'
        # Git Pull
        '[Step_2] git -> beego'
        # cd ./$Directory
        # git branch
        # git fetch
        # git pull
        # cd ..
        # Container
        docker exec $Container bash -c "rm -r $Directory_Container/$Directory_conf && rm -r $Directory_Container/$Directory_controllers && rm -r $Directory_Container/$Directory_models && rm -r $Directory_Container/$Directory_routers && rm -r $Directory_Container/$Directory_static && rm -r $Directory_Container/$Directory_views"
        '[Step_3] remove directory -> app bin config test'
        docker cp ./$Directory/$main ${Container}:$Directory_Container/$main

        docker cp ./$Directory/$Directory_conf ${Container}:$Directory_Container/$Directory_conf
        docker cp ./$Directory/$Directory_controllers ${Container}:$Directory_Container/$Directory_controllers
        docker cp ./$Directory/$Directory_models ${Container}:$Directory_Container/$Directory_models
        docker cp ./$Directory/$Directory_routers ${Container}:$Directory_Container/$Directory_routers
        docker cp ./$Directory/$Directory_static ${Container}:$Directory_Container/$Directory_static
        docker cp ./$Directory/$Directory_views ${Container}:$Directory_Container/$Directory_views
        '[Step_4] copy directory -> app bin config test'
        docker restart $Container
        '[Step_5] restart container -> beego'
        # Git Push
        # docker commit -a "Hank" -m "app" swoole asia.gcr.io/p2-stage/app
        # docker push asia.gcr.io/p2-stage/app
    }
    'Website' {
        $Directory = 'ali88_website'
        $Container = 'website'
        # Git
        '[Step_2] -> Git_Website'
        cd ./$Directory
        git branch
        git fetch
        git pull
        cd ..
        # Container
        docker restart $Container
        '[Step_3] -> Container_Website'
        docker exec $Container bash -c "rm -r $Directory && ls"
        '[Step_4] -> Remove_Directory'
        docker cp ./$Directory ${Container}:/var/www/html
        
        docker exec $Container bash -c 'chown -R www-data:www-data /var/www/html && ls'

        docker commit -a 'Hank' -m $Directory $Container asia.gcr.io/p2-stage/$Directory
        docker push asia.gcr.io/p2-stage/$Directory
    }
    Default {
        '[Step_2] -> No Param!!!'
        docker rmi $(docker images -q) -f
    }
}
# 最後執行命令的狀態
"[Error_Code] -> $lastExitCode"
"[Result] -> $?"
