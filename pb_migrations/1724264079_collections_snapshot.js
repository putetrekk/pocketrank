/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const snapshot = [
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
      "updated": "2024-08-20 15:40:48.231Z",
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
        "CREATE UNIQUE INDEX `idx_A38j2nK` ON `results` (\n  `player`,\n  `match`\n)"
      ],
      "listRule": null,
      "viewRule": null,
      "createRule": null,
      "updateRule": null,
      "deleteRule": null,
      "options": {}
    },
    {
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
    }
  ];

  const collections = snapshot.map((item) => new Collection(item));

  return Dao(db).importCollections(collections, true, null);
}, (db) => {
  return null;
})
