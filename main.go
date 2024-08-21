package main

import (
	"log"
	"net/http"

	//	"os"

	"github.com/labstack/echo/v5"
	"github.com/pocketbase/pocketbase"

	//    "github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
)

const (
	delta   = 25
	initial = 1000
)

type Matchup struct {
	Id          string `db:"id" json:"id"`
	MatchNumber int    `db:"match_number" json:"match_number"`
	Player      string `db:"player" json:"player"`
	Opponent    string `db:"opponent" json:"opponent"`
	Win         int    `db:"win" json:"win"`
}

type Match struct {
	MatchNumber int       `json:"match_number"`
	Matchups    []Matchup `json:"matchups"`
}

type Player struct {
	Id         string `json:"id"`
	Rank       int    `json:"rank"`
	RankChange int    `json:"rank_change"`
}

func main() {
	app := pocketbase.New()

	app.OnBeforeServe().Add(func(e *core.ServeEvent) error {
		e.Router.GET("/api/pocketrank/hello/:name", func(c echo.Context) error {
			name := c.PathParam("name")

			return c.JSON(http.StatusOK, map[string]string{"message": "Hello " + name})
		} /* optional middlewares */)

		return nil
	})

	app.OnBeforeServe().Add(func(e *core.ServeEvent) error {
		e.Router.GET("/api/pocketrank/get_rank/:name", func(c echo.Context) error {
			//name := c.PathParam("name")

			var matchups = []Matchup{}

			error := app.Dao().DB().NewQuery(`
				SELECT 
					(matches.id || player_results.player || opponent_results.player) as id,
				    matches.match_number as match_number,
					player_results.player as player,
					opponent_results.player as opponent,
					(player_results.place < opponent_results.place)-(player_results.place > opponent_results.place) as win
				FROM matches
					LEFT JOIN results player_results on matches.id = player_results.match
					LEFT JOIN results opponent_results on player_results.match = opponent_results.match
					and player_results.player != opponent_results.player
				`).All(&matchups)

			if error != nil {
				return c.JSON(http.StatusOK, map[string]string{"message": "Error " + error.Error()})
			}

			var matches []Match

			for _, matchup := range matchups {
				found := false
				for i, group := range matches {
					if group.MatchNumber == matchup.MatchNumber {
						matches[i].Matchups = append(group.Matchups, matchup)
						found = true
						break
					}
				}
				if !found {
					matches = append(matches, Match{
						MatchNumber: matchup.MatchNumber,
						Matchups:    []Matchup{matchup},
					})
				}
			}

			players := []Player{}

			for _, match := range matches {
				log.Println("Match Number: ", match.MatchNumber)
				for _, matchup := range match.Matchups {
					player := findPlayerOrNil(players, matchup.Player)
					if player == nil {
						players = append(players, Player{
							Id:   matchup.Player,
							Rank: initial,
						})
						player = &players[len(players)-1]
					}
					player.RankChange += matchup.Win * delta
				}
				log.Println("Sum rank change: ", sumRankChange(players))
				if match.MatchNumber == 2 {
					for _, player := range players {
						log.Println("Player: ", player.Id)
						log.Println("Rank: ", player.Rank)
						log.Println("Rank Change: ", player.RankChange)
					}
				}
				for i := range players {
					players[i].Rank += players[i].RankChange
					players[i].RankChange = 0
				}
			}

			return c.JSON(http.StatusOK, players)

		})

		return nil
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}

func sumRankChange(players []Player) int {
	sum := 0
	for _, player := range players {
		sum += player.RankChange
	}
	return sum
}

func findPlayerOrNil(players []Player, id string) *Player {
	for i, player := range players {
		if player.Id == id {
			return &players[i]
		}
	}
	return nil
}
