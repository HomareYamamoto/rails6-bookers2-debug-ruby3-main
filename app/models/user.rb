class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :book_comments, dependent: :destroy


  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy

  #一覧表示機能のための記述
  has_many :followings, through: :relationships, source: :followed
  has_many :followers, through: :reverse_of_relationships, source: :follower

  #チャット機能のための記述
  has_many :user_rooms
  has_many :rooms, through: :user_rooms
  has_many :chats

  #閲覧数表示のための記述
  has_many :read_counts, dependent: :destroy

  has_one_attached :profile_image

  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
  validates :introduction, length: { maximum: 50 }


    # フォローしたときの処理
  def follow(user_id)
    relationships.create(followed_id: user_id)
  end

    # フォローを外すときの処理
  def unfollow(user_id)
    relationships.find_by(followed_id: user_id).destroy
  end

    # フォローしているか判定
  def following?(user)
    followings.include?(user)
  end


  def self.looks(search, word,user_id)
      if search == "perfect_match"
        @user = User.where("name LIKE?", "#{word}")
      elsif search == "forward_match"
        @user = User.where("name LIKE?","#{word}%")
      elsif search == "backward_match"
        @user = User.where("name LIKE?","%#{word}")
      elsif search == "partial_match"
        @user = User.where("name LIKE?","%#{word}%")
      else
        @user = User.all
      end
  end

# "name(カラム名) LIKE?"の部分では検索に使う語句が可変である時の書き方である
# ?の部分が、第二引数#{word}）と置き換えられる。
# "#{word}"の部分で%をどこに記述するかで検索手法を指定している。

  def get_profile_image
    (profile_image.attached?) ? profile_image : 'no_image.jpg'
  end
end
