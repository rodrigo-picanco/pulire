package main

import (
	"github.com/gin-gonic/gin"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"html/template"
	"time"
)

type Task struct {
	gorm.Model
	Name          string
	LastCompleted int64
	Period        string
}

func main() {
	db := init_db()
	r := init_server()
	r.GET("/", func(c *gin.Context) {
		tasks := []Task{}
                period := c.Query("period")
                if (period == "all") {
                        db.Find(&tasks)
                } else {
                        db.Where("last_completed < strftime('%s', 'now') - period * 604800").Find(&tasks)
                }
		c.HTML(200, "tasks.tpl", gin.H{
			"tasks": tasks,
                        "period": period,
		})
	})
	r.POST("task/:id", func(c *gin.Context) {
		var task Task
		db.First(&task, c.Param("id"))
		task.LastCompleted = time.Now().Unix()
		db.Save(&task)
		c.Redirect(302, "/")
	})
	r.POST("task", func(c *gin.Context) {
		name := c.PostForm("name")
		period := c.PostForm("period")
		db.Create(&Task{Name: name, Period: period})
		c.Redirect(302, "/")
	})
	r.Run(":8080")
}

func init_server() *gin.Engine {
	r := gin.Default()
	r.SetHTMLTemplate(
		template.Must(
			template.New("").Funcs(template.FuncMap{
				"dateformat": func(ts int64) string {
                                        return time.Unix(ts, 0).Format("02/01")
				},
			}).ParseGlob("templates/*")))
	return r
}

func init_db() *gorm.DB {
	db, err := gorm.Open(sqlite.Open("pulire.db"), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}
	db.AutoMigrate(&Task{})
	return db
}
