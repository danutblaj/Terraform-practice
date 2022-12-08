package main
import (
  "os"
  "fmt"
  "net/http"
  "database/sql"

  "github.com/gin-gonic/gin"
  _ "github.com/go-sql-driver/mysql"
)

type File struct {
  Id int
  Name string
  Keyword string
  Substitute string
}

func home(c *gin.Context) {
  c.JSON(http.StatusOK, gin.H{
    "message":  "okay",
  })
}

func connect(hostname, port, database, username, password string) *sql.DB{
  connString := username + ":" + password + "@tcp(" + hostname + ":" + port + ")/" + database
  fmt.Println(connString)
  db, err := sql.Open(
    "mysql",
    connString,
  )
  if err != nil {
	panic(err)
  }

  return db
}

func query(db *sql.DB) gin.HandlerFunc {
  fn := func(c *gin.Context) {
    name := c.Param("name")
    res, err := db.Query(
      "SELECT id, filename, keyword, substitute FROM Files WHERE filename = ?",
      name,
    )
    defer res.Close()

    if err != nil {
        fmt.Println("SELECT ERROR! %s", err)
        c.JSON(http.StatusInternalServerError, "SELECT ERROR!")
        return
    }

    if res.Next() {
      var file File
      res.Scan(&file.Id, &file.Name, &file.Keyword, &file.Substitute)

      c.JSON(http.StatusOK, gin.H {
        "id": file.Id,
        "name": file.Name,
        "keyword": file.Keyword,
        "substitute": file.Substitute,
      })
    }
  }

  return gin.HandlerFunc(fn)
}

func getEnv(key, fallback string) string {
  value, exists := os.LookupEnv(key)
  if !exists {
    value = fallback
  }
  return value
}

func main() {
  hostname := getEnv("DB_HOSTNAME", "127.0.0.1")
  port     := getEnv("DB_PORT", "3306")
  username := getEnv("DB_USERNAME", "root")
  password := getEnv("DB_PASSWORD", "password")
  database := getEnv("DB_DATABASE", "DevOps")


  r := gin.Default()
  db := connect(hostname, port, database, username, password)

  r.GET("/", home)
  r.GET("/file/:name", query(db))

  r.Run()
}
