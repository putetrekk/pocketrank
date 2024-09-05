package migrations

import (
	"encoding/json"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase/daos"
	m "github.com/pocketbase/pocketbase/migrations"
	"github.com/pocketbase/pocketbase/models/schema"
)

func init() {
	m.Register(func(db dbx.Builder) error {
		dao := daos.New(db);

		collection, err := dao.FindCollectionByNameOrId("x5graoh4oy5vp52")
		if err != nil {
			return err
		}

		options := map[string]any{}
		if err := json.Unmarshal([]byte(`{
			"query": "SELECT\n  (matches.match_at || player_results.player || opponent_results.player) as id,\n  matches.match_at as match_at,\n  player_results.player as player,\n  opponent_results.player as opponent,\n  (player_results.place < opponent_results.place)-(player_results.place > opponent_results.place) as win\nFROM matches\n  LEFT JOIN results player_results on matches.id = player_results.match\n  LEFT JOIN results opponent_results on player_results.match = opponent_results.match\nand player_results.player != opponent_results.player"
		}`), &options); err != nil {
			return err
		}
		collection.SetOptions(options)

		// remove
		collection.Schema.RemoveField("dybmbgit")

		// remove
		collection.Schema.RemoveField("b5e1fngh")

		// remove
		collection.Schema.RemoveField("rcw2mhuy")

		// remove
		collection.Schema.RemoveField("p6uhehee")

		// add
		new_match_at := &schema.SchemaField{}
		if err := json.Unmarshal([]byte(`{
			"system": false,
			"id": "6bnyuqir",
			"name": "match_at",
			"type": "date",
			"required": true,
			"presentable": true,
			"unique": false,
			"options": {
				"min": "",
				"max": ""
			}
		}`), new_match_at); err != nil {
			return err
		}
		collection.Schema.AddField(new_match_at)

		// add
		new_player := &schema.SchemaField{}
		if err := json.Unmarshal([]byte(`{
			"system": false,
			"id": "1ohjyija",
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
		}`), new_player); err != nil {
			return err
		}
		collection.Schema.AddField(new_player)

		// add
		new_opponent := &schema.SchemaField{}
		if err := json.Unmarshal([]byte(`{
			"system": false,
			"id": "z1oulfoo",
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
		}`), new_opponent); err != nil {
			return err
		}
		collection.Schema.AddField(new_opponent)

		// add
		new_win := &schema.SchemaField{}
		if err := json.Unmarshal([]byte(`{
			"system": false,
			"id": "korpcsyh",
			"name": "win",
			"type": "json",
			"required": false,
			"presentable": false,
			"unique": false,
			"options": {
				"maxSize": 1
			}
		}`), new_win); err != nil {
			return err
		}
		collection.Schema.AddField(new_win)

		return dao.SaveCollection(collection)
	}, func(db dbx.Builder) error {
		dao := daos.New(db);

		collection, err := dao.FindCollectionByNameOrId("x5graoh4oy5vp52")
		if err != nil {
			return err
		}

		options := map[string]any{}
		if err := json.Unmarshal([]byte(`{
			"query": "SELECT\n  (matches.match_at || player_results.player || opponent_results.player) as id,\n  matches.match_at as match_number,\n  player_results.player as player,\n  opponent_results.player as opponent,\n  (player_results.place < opponent_results.place)-(player_results.place > opponent_results.place) as win\nFROM matches\n  LEFT JOIN results player_results on matches.id = player_results.match\n  LEFT JOIN results opponent_results on player_results.match = opponent_results.match\nand player_results.player != opponent_results.player"
		}`), &options); err != nil {
			return err
		}
		collection.SetOptions(options)

		// add
		del_match_number := &schema.SchemaField{}
		if err := json.Unmarshal([]byte(`{
			"system": false,
			"id": "dybmbgit",
			"name": "match_number",
			"type": "date",
			"required": true,
			"presentable": true,
			"unique": false,
			"options": {
				"min": "",
				"max": ""
			}
		}`), del_match_number); err != nil {
			return err
		}
		collection.Schema.AddField(del_match_number)

		// add
		del_player := &schema.SchemaField{}
		if err := json.Unmarshal([]byte(`{
			"system": false,
			"id": "b5e1fngh",
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
		}`), del_player); err != nil {
			return err
		}
		collection.Schema.AddField(del_player)

		// add
		del_opponent := &schema.SchemaField{}
		if err := json.Unmarshal([]byte(`{
			"system": false,
			"id": "rcw2mhuy",
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
		}`), del_opponent); err != nil {
			return err
		}
		collection.Schema.AddField(del_opponent)

		// add
		del_win := &schema.SchemaField{}
		if err := json.Unmarshal([]byte(`{
			"system": false,
			"id": "p6uhehee",
			"name": "win",
			"type": "json",
			"required": false,
			"presentable": false,
			"unique": false,
			"options": {
				"maxSize": 1
			}
		}`), del_win); err != nil {
			return err
		}
		collection.Schema.AddField(del_win)

		// remove
		collection.Schema.RemoveField("6bnyuqir")

		// remove
		collection.Schema.RemoveField("1ohjyija")

		// remove
		collection.Schema.RemoveField("z1oulfoo")

		// remove
		collection.Schema.RemoveField("korpcsyh")

		return dao.SaveCollection(collection)
	})
}
