class AgendasController < ApplicationController
  before_action :set_agenda, only: %i[show edit update destroy]
  before_action :owner_author_authority, only: %i[destroy]
  def index
    @agendas = Agenda.all
  end

  def new
    @team = Team.friendly.find(params[:team_id])
    @agenda = Agenda.new
  end

  def create
    @agenda = current_user.agendas.build(title: params[:title])
    @agenda.team = Team.friendly.find(params[:team_id])
    @agenda.author_id = current_user.id
    current_user.keep_team_id = @agenda.team.id
    if current_user.save && @agenda.save
      redirect_to dashboard_url, notice: 'アジェンダ作成に成功しました！'
    else
      render :new
    end
  end

  def destroy
    @agenda.destroy
    redirect_to dashboard_url, notice: 'アジェンダ削除に成功しました！'
    @team.assigns.each do |assign|
      OwnerMailer.agenda_delete_mail(assign.user.email, @agenda.title).deliver
    end
  end

  private

  def set_agenda
    @agenda = Agenda.find(params[:id])
  end

  def agenda_params
    params.fetch(:agenda, {}).permit %i[title description]
  end

  def owner_author_authority
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
    if current_user == @team.owner || @agenda.author_id == current_user.id
    else
      redirect_to team_url(@team.name), notice: "リーダーとアジェンダの作成者以外はこの操作は許可されていません。"
    end
  end
end