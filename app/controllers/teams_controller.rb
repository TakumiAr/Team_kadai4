class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy]
  before_action :owner_authority, only: [:edit, :owner_change]

  def index
    @teams = Team.all
  end

  def show
    @working_team = @team
    change_keep_team(current_user, @team)
  end

  def new
    @team = Team.new
  end

  def edit; end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: 'チーム作成に成功しました！'
    else
      flash.now[:error] = '保存に失敗しました、、'
      render :new
    end
  end

  def update
    if @team.update(team_params)
      redirect_to @team, notice: 'チーム更新に成功しました！'
    else
      flash.now[:error] = '保存に失敗しました、、'
      render :edit
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: 'チーム削除に成功しました！'
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end

  def owner_change
    @team = Team.find_by(name: params[:team_id])
    @user = User.find_by(id: params[:id])
    @team.update(owner_id: params[:id])
    redirect_to team_url(params[:team_id]), notice: '権限を移動しました！'
    OwnerMailer.owner_mail(@user.email, @team).deliver
  end

  private

  def set_team
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id]
  end

  def owner_authority
    @team = Team.find_by(name: params[:team_id])
    if current_user == @team.owner
    else
      redirect_to @team, notice: "リーダー以外はこの操作は許可されていません。"
    end
  end
end
