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
			"query": "SELECT\n  (matches.match_at || player_results.player || opponent_results.player) as id,\n  matches.match_number as match_number,\n  player_results.player as player,\n  opponent_results.player as opponent,\n  (player_results.place < opponent_results.place)-(player_results.place > opponent_results.place) as win\nFROM matches\n  LEFT JOIN results player_results on matches.id = player_results.match\n  LEFT JOIN results opponent_results on player_results.match = opponent_results.match\nand player_results.player != opponent_results.player"
		}`), &options); err != nil {
			return err
		}
		collection.SetOptions(options)

		// remove
		collection.Schema.RemoveField("zlxmlmwz")

		// remove
		collection.Schema.RemoveField("dyiljb0a")

		// remove
		collection.Schema.RemoveField("9jh680o9")

		// remove
		collection.Schema.RemoveField("xjwtjyyj")

		// add
		new_match_number := &schema.SchemaField{}
		if err := json.Unmarshal([]byte(`{
			"system": false,
			"id": "mregnkga",
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
		}`), new_match_number); err != nil {
			return err
		}
		collection.Schema.AddField(new_match_number)

		// add
		new_player := &schema.SchemaField{}
		if err := json.Unmarshal([]byte(`{
			"system": false,
			"id": "3st339tk",
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
			"id": "3v1wrauf",
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
			"id": "i8b459tw",
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
			"query": "SELECT\n  (matches.id || player_results.player || opponent_results.player) as id,\n  matches.match_number as match_number,\n  player_results.player as player,\n  opponent_results.player as opponent,\n  (player_results.place < opponent_results.place)-(player_results.place > opponent_results.place) as win\nFROM matches\n  LEFT JOIN results player_results on matches.id = player_results.match\n  LEFT JOIN results opponent_results on player_results.match = opponent_results.match\nand player_results.player != opponent_results.player"
		}`), &options); err != nil {
			return err
		}
		collection.SetOptions(options)

		// add
		del_match_number := &schema.SchemaField{}
		if err := json.Unmarshal([]byte(`{
			"system": false,
			"id": "zlxmlmwz",
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
		}`), del_match_number); err != nil {
			return err
		}
		collection.Schema.AddField(del_match_number)

		// add
		del_player := &schema.SchemaField{}
		if err := json.Unmarshal([]byte(`{
			"system": false,
			"id": "dyiljb0a",
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
			"id": "9jh680o9",
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
			"id": "xjwtjyyj",
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
		collection.Schema.RemoveField("mregnkga")

		// remove
		collection.Schema.RemoveField("3st339tk")

		// remove
		collection.Schema.RemoveField("3v1wrauf")

		// remove
		collection.Schema.RemoveField("i8b459tw")

		return dao.SaveCollection(collection)
	})
}
