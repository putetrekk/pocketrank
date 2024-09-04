package migrations

import (
	"encoding/json"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase/daos"
	m "github.com/pocketbase/pocketbase/migrations"
	"github.com/pocketbase/pocketbase/models"
)

func init() {
	m.Register(func(db dbx.Builder) error {
		jsonData := `[
			{
				"id": "_pb_users_auth_",
				"created": "2024-08-19 19:18:16.847Z",
				"updated": "2024-08-19 19:18:16.848Z",
				"name": "users",
				"type": "auth",
				"system": false,
				"schema": [
					{
						"system": false,
						"id": "users_name",
						"name": "name",
						"type": "text",
						"required": false,
						"presentable": false,
						"unique": false,
						"options": {
							"min": null,
							"max": null,
							"pattern": ""
						}
					},
					{
						"system": false,
						"id": "users_avatar",
						"name": "avatar",
						"type": "file",
						"required": false,
						"presentable": false,
						"unique": false,
						"options": {
							"mimeTypes": [
								"image/jpeg",
								"image/png",
								"image/svg+xml",
								"image/gif",
								"image/webp"
							],
							"thumbs": null,
							"maxSelect": 1,
							"maxSize": 5242880,
							"protected": false
						}
					}
				],
				"indexes": [],
				"listRule": "id = @request.auth.id",
				"viewRule": "id = @request.auth.id",
				"createRule": "",
				"updateRule": "id = @request.auth.id",
				"deleteRule": "id = @request.auth.id",
				"options": {
					"allowEmailAuth": true,
					"allowOAuth2Auth": true,
					"allowUsernameAuth": true,
					"exceptEmailDomains": null,
					"manageRule": null,
					"minPasswordLength": 8,
					"onlyEmailDomains": null,
					"onlyVerified": false,
					"requireEmail": false
				}
			},
			{
				"id": "hce9ijjuzvgrr2s",
				"created": "2024-08-19 19:33:25.777Z",
				"updated": "2024-08-20 16:04:53.023Z",
				"name": "matches",
				"type": "base",
				"system": false,
				"schema": [
					{
						"system": false,
						"id": "yk3jjx87",
						"name": "match_number",
						"type": "number",
						"required": true,
						"presentable": true,
						"unique": false,
						"options": {
							"min": null,
							"max": null,
							"noDecimal": true
						}
					}
				],
				"indexes": [],
				"listRule": null,
				"viewRule": null,
				"createRule": null,
				"updateRule": null,
				"deleteRule": null,
				"options": {}
			},
			{
				"id": "e31nq6esfq0umq8",
				"created": "2024-08-19 19:34:54.358Z",
				"updated": "2024-08-27 19:36:49.181Z",
				"name": "results",
				"type": "base",
				"system": false,
				"schema": [
					{
						"system": false,
						"id": "rlfixbiw",
						"name": "player",
						"type": "relation",
						"required": false,
						"presentable": false,
						"unique": false,
						"options": {
							"collectionId": "_pb_users_auth_",
							"cascadeDelete": false,
							"minSelect": null,
							"maxSelect": 1,
							"displayFields": null
						}
					},
					{
						"system": false,
						"id": "w9yiu8d9",
						"name": "match",
						"type": "relation",
						"required": false,
						"presentable": false,
						"unique": false,
						"options": {
							"collectionId": "hce9ijjuzvgrr2s",
							"cascadeDelete": false,
							"minSelect": null,
							"maxSelect": 1,
							"displayFields": null
						}
					},
					{
						"system": false,
						"id": "i0h3qhvz",
						"name": "place",
						"type": "number",
						"required": true,
						"presentable": true,
						"unique": false,
						"options": {
							"min": null,
							"max": null,
							"noDecimal": true
						}
					}
				],
				"indexes": [
					"CREATE UNIQUE INDEX ` + "`" + `idx_A38j2nK` + "`" + ` ON ` + "`" + `results` + "`" + ` (\n  ` + "`" + `player` + "`" + `,\n  ` + "`" + `match` + "`" + `\n)"
				],
				"listRule": "",
				"viewRule": "",
				"createRule": "",
				"updateRule": "",
				"deleteRule": "",
				"options": {}
			},
			{
				"id": "x5graoh4oy5vp52",
				"created": "2024-08-20 18:21:25.274Z",
				"updated": "2024-08-20 18:21:25.274Z",
				"name": "matchups",
				"type": "view",
				"system": false,
				"schema": [
					{
						"system": false,
						"id": "mqqpddvu",
						"name": "match_number",
						"type": "number",
						"required": true,
						"presentable": true,
						"unique": false,
						"options": {
							"min": null,
							"max": null,
							"noDecimal": true
						}
					},
					{
						"system": false,
						"id": "siqh8n4g",
						"name": "player",
						"type": "relation",
						"required": false,
						"presentable": false,
						"unique": false,
						"options": {
							"collectionId": "_pb_users_auth_",
							"cascadeDelete": false,
							"minSelect": null,
							"maxSelect": 1,
							"displayFields": null
						}
					},
					{
						"system": false,
						"id": "6amfti0h",
						"name": "opponent",
						"type": "relation",
						"required": false,
						"presentable": false,
						"unique": false,
						"options": {
							"collectionId": "_pb_users_auth_",
							"cascadeDelete": false,
							"minSelect": null,
							"maxSelect": 1,
							"displayFields": null
						}
					},
					{
						"system": false,
						"id": "vrpbdgzf",
						"name": "win",
						"type": "json",
						"required": false,
						"presentable": false,
						"unique": false,
						"options": {
							"maxSize": 1
						}
					}
				],
				"indexes": [],
				"listRule": null,
				"viewRule": null,
				"createRule": null,
				"updateRule": null,
				"deleteRule": null,
				"options": {
					"query": "SELECT\n  (matches.id || player_results.player || opponent_results.player) as id,\n  matches.match_number as match_number,\n  player_results.player as player,\n  opponent_results.player as opponent,\n  (player_results.place < opponent_results.place)-(player_results.place > opponent_results.place) as win\nFROM matches\n  LEFT JOIN results player_results on matches.id = player_results.match\n  LEFT JOIN results opponent_results on player_results.match = opponent_results.match\nand player_results.player != opponent_results.player"
				}
			},
			{
				"id": "dft63rqw15fyxa4",
				"created": "2024-09-01 21:22:35.315Z",
				"updated": "2024-09-02 17:50:00.961Z",
				"name": "available_players",
				"type": "view",
				"system": false,
				"schema": [
					{
						"system": false,
						"id": "ydkvidlu",
						"name": "name",
						"type": "text",
						"required": false,
						"presentable": false,
						"unique": false,
						"options": {
							"min": null,
							"max": null,
							"pattern": ""
						}
					}
				],
				"indexes": [],
				"listRule": "@request.auth.id != \"\"",
				"viewRule": null,
				"createRule": null,
				"updateRule": null,
				"deleteRule": null,
				"options": {
					"query": "select id, name from users;"
				}
			}
		]`

		collections := []*models.Collection{}
		if err := json.Unmarshal([]byte(jsonData), &collections); err != nil {
			return err
		}

		return daos.New(db).ImportCollections(collections, true, nil)
	}, func(db dbx.Builder) error {
		return nil
	})
}
