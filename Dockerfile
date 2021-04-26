FROM golang:latest
# ENV GOPATH /go
# 安裝環境套件
RUN apt-get update && apt-get install vim zip -y
# Install beego & bee
RUN go get github.com/astaxie/beego && \
    go get github.com/beego/bee && \
    # 更新 beego 框架
    go get -u github.com/astaxie/beego && \
    # 更新 bee 工具
    go get -u github.com/beego/bee
# 下載其他工具
RUN go get github.com/shiena/ansicolor && \
    go get gopkg.in/mgo.v2/bson && \
    go get github.com/dgrijalva/jwt-go && \
    go get github.com/garyburd/redigo/redis
# 新建 Web 項目
RUN cd /go/src && bee new beego

WORKDIR /go/src/beego
# 升級
RUN bee fix && bee update
# 下載補充套件
RUN cd /go/src/beego && \
    go mod download github.com/prometheus/client_golang && \
    go mod download github.com/shiena/ansicolor && \
    go mod download golang.org/x/crypto && \
    go mod download github.com/beorn7/perks && \
    go mod download github.com/cespare/xxhash github.com/cespare/xxhash/v2 && \
    go mod download github.com/golang/protobuf && \
    go mod download github.com/prometheus/client_model && \
    go mod download github.com/prometheus/common && \
    go mod download github.com/prometheus/procfs && \
    go mod download golang.org/x/net && \
    go mod download github.com/matttproud/golang_protobuf_extensions && \
    go mod download google.golang.org/protobuf
    # go get github.com/beego/i18n && \
    # go get github.com/beego/samples/WebIM/routers
# 執行
CMD bee run
# 背景執行
# RUN nohup go run main.go &

# 新建 Web 项目 || API 应用
# bee new beego
# bee api beego
# 背景執行
# nohup go run main.go &
