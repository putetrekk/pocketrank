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
		dao := daos.New(db)

		collection, err := dao.FindCollectionByNameOrId("xgqmsmwe2i9vcuw")
		if err != nil {
			return err
		}

		return dao.DeleteCollection(collection)
	}, func(db dbx.Builder) error {
		jsonData := `{
			"id": "xgqmsmwe2i9vcuw",
			"created": "2024-08-20 15:30:26.715Z",
			"updated": "2024-08-20 18:21:25.317Z",
			"name": "rank_history",
			"type": "view",
			"system": false,
			"schema": [
				{
					"system": false,
					"id": "v1p7mxjy",
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
					"id": "atgzkane",
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
					"id": "2ex0aewk",
					"name": "place",
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
				"query": "WITH matchups as (\n  SELECT\n    matches.match_number as match_number,\n    results.player as player,\n    results.place as place,\n    MIN(matches.match_number) over (PARTITION BY results.player) as first_match\n    FROM matches\n    LEFT JOIN results on matches.id = results.match\n)\nselect\n  (match_number || player) as id,\n  match_number as match_number,\n  player as player,\n  place as place\nfrom matchups;"
			}
		}`

		collection := &models.Collection{}
		if err := json.Unmarshal([]byte(jsonData), &collection); err != nil {
			return err
		}

		return daos.New(db).SaveCollection(collection)
	})
}
