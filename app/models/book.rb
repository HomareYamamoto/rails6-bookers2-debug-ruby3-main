class Book < ApplicationRecord
  belongs_to :user
  has_many :favorites, dependent: :destroy
  # has_many :favorited_users, through: :favorites, source: :user
  has_many :book_comments, dependent: :destroy
  has_many :read_counts, dependent: :destroy

  validates :title,presence:true
  validates :body,presence:true,length:{maximum:200}


  def self.looks(search, word,user_id)
    if search == "perfect_match"
      @book = Book.where("title LIKE?","#{word}")
    elsif search == "forward_match"
      @book = Book.where("title LIKE?","#{word}%")
    elsif search == "backward_match"
      @book = Book.where("title LIKE?","%#{word}")
    elsif search == "partial_match"
      @book = Book.where("title LIKE?","%#{word}%")
    else
      @book = Book.all
    end
  end

# "title(カラム名) LIKE?"の部分では検索に使う語句が可変である時の書き方である
# ?の部分が、第二引数#{word}）と置き換えられる。
# "#{word}"の部分で%をどこに記述するかで検索手法を指定している。

  def favorited_by?(user)
    favorites.exists?(user_id: user.id)
  end

end