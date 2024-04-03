class BooksController < ApplicationController
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def show
    @book = Book.find(params[:id])
    @book_comment = BookComment.new
    @user=@book.user
  end

  def index
    # @books = Book.all 以前まで記述していたコード
    @book = Book.new
    @user=current_user
    to = Time.current.at_end_of_day # config/application.rbに設定してあるタイムゾーンを元に現在日時を取得しています。at_end_of_day は1日の終わりを23:59に設定しています。
    from = (to - 6.day).at_beginning_of_day # at_beginning_of_day　は1日の始まりの時刻を0:00に設定しています。
    @books = Book.all.sort {|a,b|
      a.favorites.where(created_at: from...to).size <=>
      b.favorites.where(created_at: from...to).size
    }.reverse

    #sort_byを使ったやり方のほうが記述がシンプルで分かりやすいがなぜか機能しない。
    # @books = Book.includes(:favorited_users).
    # # ここまでを要約すると一週間分のデータとってきたよーって感じ
    #   sort_by {|x|
    #     x.favorited_users.includes(:favorites).where(created_at: from...to).size
    #   }.reverse

  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      redirect_to book_path(@book.id), notice: "You have created book successfully."
    else
      @books = Book.all
      render 'index'
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to book_path(@book.id), notice: "You have updated book successfully."
    else
      render "edit"
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :body, )
  end


  def ensure_correct_user
    @book = Book.find(params[:id])
    unless @book.user == current_user
      redirect_to books_path
    end
  end


end
