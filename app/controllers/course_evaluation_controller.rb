class CourseEvaluationController < ApplicationController
  #added the below lines E913
  include AccessHelper
  before_filter :auth_check

  def action_allowed?
    if current_user.role.name.eql?("Student")
      true
    end
  end

  #our changes end E913
  def list #list course evaluations for a user
    unless session[:user] #Check for a valid user
      redirect_to '/'
      return 
    end    
    deployments=SurveyParticipant.find_all_by_user_id(session[:user].id)
    @surveys=Array.new
    deployments.each do |sd|
      survey_deployment=SurveyDeployment.find(sd.survey_deployment_id)
      if(Time.now>survey_deployment.start_date && Time.now<survey_deployment.end_date)
        @surveys<<[Questionnaire.find(survey_deployment.course_evaluation_id),sd.survey_deployment_id,survey_deployment.end_date, survey_deployment.course_id]
      end
     end
   end
  
end
