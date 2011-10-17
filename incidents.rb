require 'rubygems'
require 'sinatra'
require 'haml'
require 'jiraSOAP'
require 'openssl'
require 'yaml'

get('/') do
  @config = YAML::load(File.open('incidents.yml'))
  jira_url = @config['sites']['jira']
  @jira = JIRA::JIRAService.new jira_url
  @jira.login @config['user'], @config['passwd']

  @issues = @jira.issues_from_filter_with_id(@config['issueId']).sort_by(&:create_time)
  @lastIncident = @issues.last
  @lastIncidentUrl = [jira_url, 'browse', @lastIncident.key].join('/')
  @days = @issues.map { |x| to_days(x.create_time).round }

  @daysSinceLast = @days.last
  @daysBetweenLastTwo = @days[-2] - @daysSinceLast
  @recordStreak = max_days @days

  haml :index
end

# todo truncate times
def to_days(created)
   Date.today - created.to_date
end

def max_days(issues)
   issues.each_cons(2).map{ |x, y| x - y }.max
end
