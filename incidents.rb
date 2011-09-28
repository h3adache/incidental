require 'rubygems'
require 'sinatra'
require 'haml'
require 'jiraSOAP'
require 'openssl'
require 'yaml'

get('/') do
  @config = YAML::load(File.open('incidents.yml'))
  @jira = JIRA::JIRAService.new @config['sites']['jira']
  @jira.login @config['user'], @config['passwd']

  @issues = @jira.issues_from_filter_with_id(@config["issueId"]).sort_by(&:create_time)
  @lastIncident = @issues.last
  @days = @issues.map { |x| toDays(x.create_time).round }

  @daysSinceLast = @days.last
  @daysBetweenLastTwo = @days[-2] - @daysSinceLast
  @recordStreak = maxDays(@days)

  haml :index
end

# todo truncate times
def toDays(created)
   Date.today - created.to_date
end

def maxDays(issues)
   issues.each_cons(2).map{ |x, y| x - y }.max
end
