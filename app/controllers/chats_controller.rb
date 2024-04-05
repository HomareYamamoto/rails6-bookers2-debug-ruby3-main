class ChatsController < ApplicationController
  before_action :following_check, only: [:show]

  def show
    @user = User.find(params[:id])#① 送られてきたidでUserを検索
    rooms = current_user.user_rooms.pluck(:room_id) #② current_userの持つroom_idを取得
    user_rooms = UserRoom.find_by(user_id: @user.id, room_id: rooms) #③ ①と②を用いて合致するUserRoomが有るか探す
    if user_rooms.nil? #　③がnil、つまり見つからなかった場合
      chat_room = Room.new #　新しくRoomを作成
      chat_room.save
      UserRoom.create(user_id: current_user.id, room_id: chat_room.id)
      UserRoom.create(user_id: @user.id, room_id: chat_room.id)
      #　新しくUserRoomを作成(createは保存も同時に行われるのでsave不要)
    else
      chat_room = user_rooms.room #user_roomのroomの情報を抜き出す ＝ roomのidを取得
      #roomはuserモデルで記載したhas_many :room, through: :user_rooms のroom
    end
    @room = chat_room
    @chats = @room.chats #roomのidに合致するchatの内容を取得する
    #chatsはuserモデルで記載したhas_many :chats　のchats
    @chat = Chat.new(room_id: chat_room.id) #空のインスタンスの作成
  end


  def create
    @chat = current_user.chats.new(chat_params)
    @chat.save
    redirect_to request.referer
  end

  private
  def chat_params
    params.require(:chat).permit(:message, :room_id)
  end


  def following_check
    user = User.find(params[:id])
    unless current_user.following?(user) && user.following?(current_user)
      redirect_to books_path
    end
  end

end
