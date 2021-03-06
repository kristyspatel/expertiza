class AdviceController < ApplicationController
  #added the below lines E913
  include AccessHelper
  before_filter :auth_check

  def action_allowed?
    if current_user.role.name.eql?("Administrator") || current_user.role.name.eql?("Instructor") || current_user.role.name.eql?("Teaching Assistant")
      true
    end
  end

  #our changes end E913
  # Modify the advice associated with a questionnaire
  def edit_advice
    @questionnaire = get(Questionnaire, params[:id])

    for question in @questionnaire.questions
      if question.true_false
        num_questions = 2
      else
        num_questions = @questionnaire.max_question_score - @questionnaire.min_question_score
      end

      sorted_advice = question.question_advices.sort_by { |x| -x.score }
      if question.question_advices.length != num_questions or
          sorted_advice[0].score != @questionnaire.min_question_score or
          sorted_advice[sorted_advice.length-1] != @questionnaire.max_question_score
        #  The number of advices for this question has changed.
        QuestionnaireHelper::adjust_advice_size(@questionnaire, question)
      end
    end
  end

  # save the advice for a questionnaire
  def save_advice
    @questionnaire = get(Questionnaire, params[:id])

    begin
      for advice_key in params[:advice].keys
        QuestionAdvice.update(advice_key, params[:advice][advice_key])
      end
      flash[:notice] = "The questionnaire's question advice was successfully saved"
      redirect_to :action => 'edit_advice', :id => params[:id]

    rescue ActiveRecord::RecordNotFound
      render :action => 'edit_advice', :id => params[:id]
    end
  end
end
