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

		collection, err := dao.FindCollectionByNameOrId("hce9ijjuzvgrr2s")
		if err != nil {
			return err
		}

		// remove
		collection.Schema.RemoveField("yk3jjx87")

		return dao.SaveCollection(collection)
	}, func(db dbx.Builder) error {
		dao := daos.New(db);

		collection, err := dao.FindCollectionByNameOrId("hce9ijjuzvgrr2s")
		if err != nil {
			return err
		}

		// add
		del_match_number := &schema.SchemaField{}
		if err := json.Unmarshal([]byte(`{
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
		}`), del_match_number); err != nil {
			return err
		}
		collection.Schema.AddField(del_match_number)

		return dao.SaveCollection(collection)
	})
}
