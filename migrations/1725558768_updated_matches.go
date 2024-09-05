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
		dao := daos.New(db)

		collection, err := dao.FindCollectionByNameOrId("hce9ijjuzvgrr2s")
		if err != nil {
			return err
		}

		// add
		new_match_at := &schema.SchemaField{}
		if err := json.Unmarshal([]byte(`{
			"system": false,
			"id": "scczdrvf",
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

		return dao.SaveCollection(collection)
	}, func(db dbx.Builder) error {
		dao := daos.New(db)

		collection, err := dao.FindCollectionByNameOrId("hce9ijjuzvgrr2s")
		if err != nil {
			return err
		}

		// remove
		collection.Schema.RemoveField("scczdrvf")

		return dao.SaveCollection(collection)
	})
}
