# Some tips and examples

## Content of the retrieved vault JSON
* There are only 1 actual file and metadata file in this vault.
  * `jq -r . MyVaut_inventory_content.json`
    ~~~
    {
      "VaultARN": "arn:aws:glacier:eu-west-1:518797111111:vaults/MyVaut",
      "InventoryDate": "2021-09-12T22:48:25Z",
      "ArchiveList": [
        {
          "ArchiveId": "1111111111111111111111111111111-sfYveO3Eo5dpUYsMnolTXoXQyYr1Qj-O37ny8-YrzewW-3IVUFdzB_tqlF7BYuawEyRQSBUtZmL90kpKZ1HzSSa8lDtGq3in8zkpVvGw",
          "ArchiveDescription": "{\"path\": \"/path/to/file/joujou.ova\", \"type\": \"file\"}",
          "CreationDate": "2018-08-23T14:55:50Z",
          "Size": 2314362961920,
          "SHA256TreeHash": "0cc67088830c637a55b3bd800aaaf3d5ce7c2e767e7ecbdc4caf333333333333"
        },
        {
          "ArchiveId": "222222222222222222222222222222222222-VeXsuhqQadbDixxFiF3OZaaGlr38a2VJ9ist5bz_E1eiYSqZKD8fRxHm7LJhJ7JZ4NJDH552V3Cw9uinlYT9H4qOdWt6yAnpJGZYGA",
          "ArchiveDescription": "{\"type\": \"metadata\"}",
          "CreationDate": "2019-01-18T23:31:33Z",
          "Size": 31737,
          "SHA256TreeHash": "59735ffa629f93f6216fa7e66a1af656d85144300c190008144444444444444"
        }
      ]
    }
    ~~~
