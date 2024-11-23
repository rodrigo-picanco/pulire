package main

import (
	"github.com/gin-gonic/gin"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"html/template"
	"strconv"
	"time"
)

type Task struct {
	gorm.Model
	Name      string
	Period    int
	RoomID    int
        UpdatedAt time.Time
}

type Room struct {
	gorm.Model
	Name  string
	Tasks []Task
}

// TODO: Render by rooms preloading tasks 
func main() {
	db := init_db()
	r := init_server()
	r.GET("/", func(c *gin.Context) {
		period := c.Query("period")
                var rooms []Room
                if period == "all" { 
                        rooms = get_rooms(db)
                } else {
                        rooms = get_due_rooms(db) }
		c.HTML(200, "tasks.tpl", gin.H{
			"Filter": period,
                        "Rooms":  rooms,
		})
	})
	r.GET("task/:id", func(c *gin.Context) {
		var task Task
		db.First(&task, c.Param("id"))
		db.Save(&task)
		c.Redirect(302, c.Request.Referer())
	})
	r.GET("task/:id/delete", func(c *gin.Context) {
		var task Task
		db.First(&task, c.Param("id"))
		db.Delete(&task)
		c.Redirect(302, c.Request.Referer())
	})
        r.POST("room", func(c *gin.Context) {
                name := c.PostForm("name")
                db.Create(&Room{Name: name})
                c.Redirect(302, c.Request.Referer())
        })
	r.POST("task", func(c *gin.Context) {
		name := c.PostForm("name")
		period := c.PostForm("period")
		roomID, err := strconv.Atoi(c.PostForm("room"))
		if err != nil {
                        panic(err)
		}
                periodInt, err := strconv.Atoi(period)
                if err != nil {
                        panic(err)
                }
		db.Create(&Task{Name: name, Period: periodInt, RoomID: roomID})
		c.Redirect(302, c.Request.Referer())
	})
	r.Run(":8080")
}

func get_due_rooms(db *gorm.DB) []Room {
        rooms := []Room{}
        db.Preload("Tasks", "datetime('now', 'localtime') > datetime(updated_at,  (period * 7) || ' days', 'localtime')").Find(&rooms)
        return rooms
}

func get_rooms(db *gorm.DB) []Room {
        rooms := []Room{}
        db.Preload("Tasks").Find(&rooms)
        return rooms
}

func init_server() *gin.Engine {
	r := gin.Default()
	r.SetHTMLTemplate(
		template.Must(
			template.New("").Funcs(template.FuncMap{
				"dateformat": func(ts time.Time) string {
					return ts.Format("02/01")
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
	db.AutoMigrate(&Room{})
	return db
}
