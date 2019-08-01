class OwnerMailer < ApplicationMailer
    default from: 'from@example.com'

    def owner_mail(email, team)
        @email = email
        @team = team
        mail to: @email, subject: "#{@team.name}のリーダー権を付与されました！"
    end

    def agenda_delete_mail(email, title)
        @email = email
        @title = title
        mail to: @email, subject: "#{title}が削除されました！"
    end
end
