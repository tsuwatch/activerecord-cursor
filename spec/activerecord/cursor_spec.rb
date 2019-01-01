require 'spec_helper'

describe ActiveRecord::Cursor do
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end

  class Post < ApplicationRecord; end

  it { expect(Post).to respond_to(:cursor) }

  describe '.cursor' do
    let!(:post0) { Post.create(score: 0, published: true) }
    let!(:post1) { Post.create(score: 1, created_at: 1.day.after) }
    let!(:post11) { Post.create(score: 1, published: true, created_at: 2.day.after) }
    let!(:post2) { Post.create(score: 2, created_at: 3.day.after) }

    it { expect(Post.cursor).to eq [post0] }

    context 'key created_at' do
      it do
        expect(
          Post.where(published: true).cursor(key: :created_at)
        ).to eq [post0]
        expect(
          Post.where(published: true).cursor(
            key: :created_at,
            start: Post.next_cursor
          )
        ).to eq [post11]
      end
    end

    context 'key score' do
      it do
        expect(Post.cursor(key: :score, size: 2)).to eq [post0, post1]
        expect(Post.prev_cursor).to eq nil
        expect(
          Post.cursor(
            key: :score,
            size: 2,
            start: Post.next_cursor
          )
        ).to eq [post11, post2]
        expect(
          Post.cursor(
            key: :score,
            size: 2,
            stop: Post.prev_cursor
          )
        ).to eq [post0, post1]
      end

      context 'same score' do
        it do
          expect(
            Post.cursor(
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
          expect(Post.cursor(key: :score, size: 2, reverse: true)).to eq [post2, post11]
          expect(ActiveRecord::Cursor::Params.decode(Post.next_cursor).value).to eq('id' => 3, 'key' => 1)
          expect(Post.prev_cursor).to eq nil
          expect(
            Post.cursor(
              key: :score,
              size: 2,
              reverse: true,
              start: Post.next_cursor
            )
          ).to eq [post1, post0]
          expect(
            Post.cursor(key: :score, size: 2, reverse: true, stop: Post.prev_cursor)
          ).to eq [post2, post11]
        end
      end
    end
  end
end
