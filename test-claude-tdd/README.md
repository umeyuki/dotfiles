# Claude Code TDD Test Projects

このディレクトリには、Claude Code Hooksの自動テスト実行機能をテストするためのサンプルプロジェクトが含まれています。

## プロジェクト構成

### JavaScript (Node.js)
- `index.js` - 簡単な計算機能の実装
- `test.js` - Node.js標準のテストコード
- `package.json` - プロジェクト設定

テスト実行:
```bash
npm test
```

### Python
- `python/calculator.py` - 計算機能の実装
- `python/test_calculator.py` - unittestを使用したテスト
- `python/requirements.txt` - 依存関係

テスト実行:
```bash
cd python
python -m unittest test_calculator.py
# または
python -m pytest
```

### Go
- `go/calculator.go` - 計算機能の実装
- `go/calculator_test.go` - Go標準のテスト
- `go/go.mod` - モジュール設定

テスト実行:
```bash
cd go
go test
```

## TDD実践例

1. **Red Phase**: まず失敗するテストを書く
2. **Green Phase**: テストを通す最小限の実装をする
3. **Refactor Phase**: コードを改善する

Claude Code Hooksにより、ファイル編集時に自動でテストが実行され、TDDサイクルをスムーズに進められます。