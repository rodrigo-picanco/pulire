package main

import (
	"errors"
	"github.com/gin-gonic/gin"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"html/template"
	"os"
	"strconv"
	"time"
)

type Task struct {
	gorm.Model
	Name      string
	Period    int
	RoomID    uint
	UpdatedAt time.Time
	CreatedAt time.Time
}

type Room struct {
	gorm.Model
	Name  string
	Tasks []Task
}

func main() {
	db := initDb()
	r := initServer()
	r.GET("/", func(c *gin.Context) {
		tasks_filter := c.Query("tasks")
		var rooms []Room
		if tasks_filter == "all" {
			db.Preload("Tasks").Find(&rooms)
		} else {
			db.Preload("Tasks", `
                                datetime('now', 'localtime') > datetime(
                                        updated_at,
                                        (CASE WHEN period > 1 THEN (period * 7) ELSE 3 END) || ' days',
                                        'localtime'
                                ) 
                                OR updated_at == created_at
                        `).Find(&rooms)
                                
		}
		c.HTML(200, "tasks.tpl", gin.H{
			"Filter": tasks_filter,
			"Rooms":  rooms,
		})
	})
	r.POST("task", func(c *gin.Context) {
		name := c.PostForm("name")
		period, err := strconv.Atoi(c.PostForm("period"))
		if err != nil {
			panic(err)
		}
		roomName := c.PostForm("room")
		var room Room
		result := db.Where("name = ?", roomName).First(&room)
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			room = Room{Name: roomName}
			db.Create(&room)
		}
		db.Create(&Task{Name: name, Period: period, RoomID: room.ID})
		c.Redirect(302, c.Request.Referer())
	})
	r.GET("task/:id", func(c *gin.Context) {
		var task Task
		db.First(&task, c.Param("id"))
		db.Save(&task)
		c.Redirect(302, c.Request.Referer())
	})
	r.GET("task/:id/delete", func(c *gin.Context) {
		db.Transaction(func(tx *gorm.DB) error {
			var task Task
			if err := tx.First(&task, c.Param("id")).Error; err != nil {
				return err
			}
			if err := tx.Delete(&task).Error; err != nil {
				return err
			}
			var exists bool
			if err := tx.Model(&Task{}).
				Select("1").
				Where("room_id = ?", task.RoomID).
				Limit(1).
				Scan(&exists).Error; err != nil {
				return err
			}
			if !exists {
				if err := tx.Delete(&Room{}, task.RoomID).Error; err != nil {
					return err
				}
			}
			return nil
		})
		c.Redirect(302, c.Request.Referer())
	})
	r.Run(":8080")
}

func initServer() *gin.Engine {
	r := gin.Default()
	r.SetHTMLTemplate(
		template.Must(
			template.New("").Funcs(
				template.FuncMap{
					"dateformat": func(ts time.Time) string {
						return ts.Format("02/01")
					},
				}).ParseGlob("templates/*"),
		),
	)
	return r
}

func initDb() *gorm.DB {
	dbPath := os.Getenv("DB_PATH")
	if dbPath == "" {
		dbPath = "db.sqlite3"
	}
	db, err := gorm.Open(sqlite.Open(dbPath), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}
	db.AutoMigrate(&Task{})
	db.AutoMigrate(&Room{})
	return db
}
