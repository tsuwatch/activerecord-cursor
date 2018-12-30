require 'spec_helper'

describe ActiveRecord::Cursor do
  class Post < ActiveRecord::Base; end

  it { expect(Post).to respond_to(:cursor_page) }

  describe '.cursor_page' do
    let(:created_at) { Time.now }
    let!(:post0) do
      Post.create(score: 0, published: true, created_at: created_at)
    end
    let!(:post1) { Post.create(score: 1) }
    let!(:post11) { Post.create(score: 1, published: true) }
    let!(:post2) { Post.create(score: 2) }

    it { expect(Post.cursor_page).to eq [post0] }

    context 'key created_at' do
      it do
        expect(
          Post.where(published: true).cursor_page(key: :created_at)
        ).to eq [post0]
        expect(
          YAML.safe_load(
            Base64.urlsafe_decode64(Post.cursor_start),
            [Symbol, Time]
          )
        ).to eq(id: 1, key: created_at)
        expect(
          Post.where(published: true).cursor_page(
            key: :created_at,
            start: Post.cursor_start
          )
        ).to eq [post11]
      end
    end

    context 'key score' do
      it do
        expect(Post.cursor_page(key: :score)).to eq [post0]
        expect(
          YAML.safe_load(
            Base64.urlsafe_decode64(Post.cursor_start),
            [Symbol]
          )
        ).to eq(id: 1, key: 0)
        expect(Post.cursor_stop).to eq nil
        expect(
          Post.cursor_page(
            key: :score,
            start: Post.cursor_start
          )
        ).to eq [post1]
      end

      context 'same score' do
        it do
          expect(
            Post.cursor_page(
              key: :score,
              start: Base64.urlsafe_encode64({
                id: post1.id,
                key: post1.score
              }.to_yaml)
            )
          ).to eq [post11]
        end
      end

      context 'reverse true' do
        it do
          expect(Post.cursor_page(key: :score, reverse: true)).to eq [post2]
          expect(
            YAML.safe_load(
              Base64.urlsafe_decode64(Post.cursor_start),
              [Symbol]
            )
          ).to eq(id: 4, key: 2)
          expect(Post.cursor_stop).to eq nil
          expect(
            Post.cursor_page(
              key: :score,
              reverse: true,
              start: Post.cursor_start
            )
          ).to eq [post11]
          expect(
            Post.cursor_page(key: :score, reverse: true, stop: Post.cursor_stop)
          ).to eq [post2]
        end
      end
    end
  end
end
