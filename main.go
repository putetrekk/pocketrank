package main

import (
	"log"
	"net/http"
	"os"
	"sort"
	"strings"

	"math"

	"github.com/labstack/echo/v5"
	"github.com/pocketbase/pocketbase"

	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/plugins/migratecmd"
)

const (
	k       = 25
	initial = 1000
)

type Matchup struct {
	MatchNumber  int    `db:"match_number" json:"match_number"`
	Player       string `db:"player" json:"player"`
	PlayerName   string `db:"player_name" json:"player_name"`
	Opponent     string `db:"opponent" json:"opponent"`
	OpponentName string `db:"opponent_name" json:"opponent_name"`
	Win          int    `db:"win" json:"win"`
}

type Match struct {
	MatchNumber int       `json:"match_number"`
	Matchups    []Matchup `json:"matchups"`
}

type Player struct {
	Id         string `json:"id"`
	Name       string `json:"name"`
	Rank       int    `json:"rank"`
	RankChange int    `json:"rank_change"`
}

func main() {
	app := pocketbase.New()

	// loosely check if it was executed using "go run"
	isGoRun := strings.HasPrefix(os.Args[0], os.TempDir())

	migratecmd.MustRegister(app, app.RootCmd, migratecmd.Config{
		Automigrate: isGoRun,
	})

	app.OnBeforeServe().Add(func(e *core.ServeEvent) error {
		e.Router.GET("/api/pocketrank/hello/:name", func(c echo.Context) error {
			name := c.PathParam("name")

			return c.JSON(http.StatusOK, map[string]string{"message": "Hello " + name})
		} /* optional middlewares */)

		return nil
	})

	app.OnBeforeServe().Add(func(e *core.ServeEvent) error {
		e.Router.GET("/api/pocketrank/ratings", func(c echo.Context) error {

			var matchups = []Matchup{}

			error := app.Dao().DB().NewQuery(`
        SELECT 
            matches.match_number as match_number,
            player_results.player as player,
			player_user.name as player_name,
            opponent_results.player as opponent,
			opponent_user.name as opponent_name,
            (player_results.place < opponent_results.place)-(player_results.place > opponent_results.place) as win
        FROM matches
            LEFT JOIN results player_results on matches.id = player_results.match
            LEFT JOIN results opponent_results on player_results.match = opponent_results.match
            and player_results.player != opponent_results.player
			LEFT JOIN users player_user on player_results.player = player_user.id
			LEFT JOIN users opponent_user on opponent_results.player = opponent_user.id

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

			players := make([]Player, 0, len(matchups))

			for _, match := range matches {
				log.Println("Match Number: ", match.MatchNumber)
				for _, matchup := range match.Matchups {
					var player, opponent *Player
					players, player, opponent = retrievePlayers(players, matchup)
					expected_score := 1 / (1 + math.Pow(10, float64(opponent.Rank-player.Rank)/400))
					actual_score := 0.5 + 0.5*float64(matchup.Win)
					rankChange := int(k * (actual_score - expected_score))
					player.RankChange += rankChange
				}
				for i := range players {
					players[i].Rank += players[i].RankChange
					players[i].RankChange = 0
				}
			}

			sort.Slice(players, func(i, j int) bool {
				return players[i].Rank > players[j].Rank
			})

			return c.JSON(http.StatusOK, players)
		}, apis.RequireAdminOrRecordAuth())
		return nil
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}

func retrievePlayers(players []Player, matchup Matchup) ([]Player, *Player, *Player) {
	player := findPlayerOrNil(players, matchup.Player)
	if player == nil {
		players = append(players, Player{
			Id:   matchup.Player,
			Name: matchup.PlayerName,
			Rank: initial,
		})
		player = findPlayerOrNil(players, matchup.Player)
	}
	opponent := findPlayerOrNil(players, matchup.Opponent)
	if opponent == nil {
		players = append(players, Player{
			Id:   matchup.Opponent,
			Name: matchup.OpponentName,
			Rank: initial,
		})
		opponent = findPlayerOrNil(players, matchup.Opponent)
	}
	return players, player, opponent
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
