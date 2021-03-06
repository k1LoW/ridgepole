describe 'Ridgepole::Client#diff -> migrate', condition: 5.1 do
  context 'when add virtual column' do
    let(:actual_dsl) {
      <<-EOS
        create_table "books", force: :cascade do |t|
          t.string  "title"
          t.index ["title"], name: "index_books_on_title"
        end
      EOS
    }

    let(:expected_dsl) {
      <<-EOS
        create_table "books", force: :cascade do |t|
          t.string   "title"
          t.virtual  "upper_title", type: :string, as: "upper(`title`)"
          t.virtual  "title_length", type: :integer, as: "length(`title`)", stored: true
          t.index ["title"], name: "index_books_on_title"
          t.index ["title_length"], name: "index_books_on_title_length"
        end
      EOS
    }

    before { subject.diff(actual_dsl).migrate }
    subject { client }

    it {
      delta = subject.diff(expected_dsl)
      expect(delta.differ?).to be_truthy
      expect(subject.dump).to match_fuzzy actual_dsl
      delta.migrate
      expect(subject.dump).to match_fuzzy expected_dsl
    }
  end
end
