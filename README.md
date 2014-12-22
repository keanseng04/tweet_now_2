Building on <a href="http://learn.codedivision.my/challenges/139">Tweet Now! 1: Single User</a>, let's add support for logging in with Twitter. This will be our first application that uses OAuth for authentication.

Twitter uses <a href="http://oauth.net/core/1.0a/">OAuth version 1</a> for API authorization. OAuth (and particularly, OAuth version 1) is hard. Thanks to the power of Google, the Internet and the generous Ruby community, we found an example application that was meticulously documented with example code of how to use with Twitter's OAuth <em>(which allows your users to login to your app via Twitter and grant permission to tweet on their behalves)</em>. Find the example code here: <a href="https://github.com/code-division/sign_in_with_twitter_sample">Sign in with Twitter Example</a>
<h2>Objectives</h2>
Create an application that allows a user to sign in via Oauth from Twitter and then send a tweet.
<h3>Read through the example application</h3>
<a href="https://github.com/code-division/sign_in_with_twitter_sample">Sign in with Twitter Example</a>

<strong>BEFORE</strong> you start, spend time reading the <a href="https://dev.twitter.com/docs/auth/oauth">Twitter OAuth Documentation</a> and familiarize yourself with the basics of OAuth version 1 and especially <a href="https://dev.twitter.com/web/sign-in/implementing">Sign in via Twitter</a> and <a href="https://dev.twitter.com/oauth/3-legged">3-legged authorization</a>. See if you can relate what you learn to the image below.
<h3>Configuring Your Environment</h3>
Your Twitter "consumer key" and "consumer secret" answer the question, "What application is doing the acting?"

The application skeleton we've provided expects you to have <code>TWITTER_KEY</code> and <code>TWITTER_SECRET</code> environment variables defined for your running server. This is so that we can deploy things securely to Heroku later.

You can set these keys in your 'yaml' file that will not be uploaded to Heroku or Github.

Or, for a quick start you can simply <code>export</code> these environment variables before we run <code>shotgun</code> (these will only be available for the current session):
<div class="highlight">
<pre><span class="nv">$ </span><span class="nb">export </span><span class="nv">TWITTER_KEY</span><span class="o">=</span>&lt;your_twitter_consumer_key&gt;
<span class="nv">$ </span><span class="nb">export </span><span class="nv">TWITTER_SECRET</span><span class="o">=</span>&lt;your_twitter_consumer_secret&gt;
<span class="nv">$ </span>shotgun
</pre>
</div>
Since you are using OAuth, you will also need to set a <code>callback function</code> which is the route the application wil be directed to after the user is authenticated. When you are using localhost, this callback function is actually set in the request token (see the helper method in your skeleton), BUT you still need to set something in the callback field when registering your application with Twitter. As you can read in <a href="https://dev.twitter.com/discussions/5749">this post</a> you can actually set this to any valid url and it will be overwritten by the attribute of your request token.
<h3>Getting It Running Without Code Changes</h3>
Unlike your previous Twitter applications, the "access token" and "access token secret" will have to change <em>depending on what user is currently authenticated</em>. This key pair answers the question, "On whose behalf is this application acting?"

Twitter needs to answer both of these questions to make sure that the application is valid and that the application can only do what it has permission to do on behalf of an authenticated user.

The core OAuth flow goes like this:
<ol>
	<li>Application generates URL to "Sign In with Twitter".</li>
	<li>Application renders page with "Sign In with Twitter" link</li>
	<li>User clicks "Sign In with Twitter"</li>
	<li>User is redirected to Twitter and authorizes the application</li>
	<li>User is redirected back to the application's callback URL</li>
	<li>Application verifies the redirection from Twitter is valid</li>
	<li>If valid, Application takes appropriate action</li>
</ol>
Assuming you've configured things properly, the skeleton app should just run out of the box. However, the skeleton app doesn't do anything related to creating the user, logginer her in, etc. You'll need to implement that part on your own later. For now, though, just make sure the application skeleton works (which will prove that your environment and Twitter application are configured correctly).
<h3>Create Users with Access Tokens in Database</h3>
Now you'll need to implement that last step of the OAuth flow. Specifically, you'll need to create the new user, set her as "logged in", store her access token and secret along with her user record, etc. This should happen inside of the<code>/auth</code> route in your <code>controllers/index.rb</code> file:
<div class="highlight">
<pre>get <span class="s1">'/auth'</span> <span class="k">do</span>
  <span class="c"># the `request_token` method is defined in `app/helpers/oauth.rb`</span>
  @access_token <span class="o">=</span> request_token.get_access_token<span class="o">(</span>:oauth_verifier <span class="o">=</span>&gt; params<span class="o">[</span>:oauth_verifier<span class="o">])</span>
  <span class="c"># our request token is only valid until we use it to get an access token, so let's delete it from our session</span>
  session.delete<span class="o">(</span>:request_token<span class="o">)</span>

  <span class="c"># at this point in the code is where you'll need to create your user account and store the access token</span>

  erb :index
end
</pre>
</div>
We'll want a <code>User</code> model, however the user won't have a password. Instead, the user will be authenticated via OAuth. With OAuth there's not necessarily a distinction between signing up and logging in - the first time a user authenticates via Twitter we can create the <code>User</code> object. Instead of a password, you'll want to have columns to store her "access token" and "access token secret".
<h3>Tweet on behalf of your user</h3>
Now that you have an authenticated user who has authorized you to use Twitter on their behalf, revisit your "Tweet Now!" app and send some tweets for this user.
<h3>How the OAuth (v1) Conversation Works</h3>
<img src="http://code-division.s3.amazonaws.com/learning_portal/static_assets/images/oauth.png" alt="" />
<h3>Deploying Securely to Heroku</h3>
<strong>STOP</strong> - Go find your laptop and use it to deploy to Heroku - please (no really please) do not reset the SSH keys on Code Division machines.

We don't want our confidential information (like application keys and secrets) to be stored in git, especially if we're going to push this to a public repository. If we <em>were</em> to store them in a public repository, anyone would be able to pretend to be our application. <strong>NOT good.</strong>

Configuring the <code>TWITTER_KEY</code> and <code>TWITTER_SECRET</code> environment variables on our local machine was easy. <a href="https://devcenter.heroku.com/articles/config-vars">On Heroku, it's slighly more complicated</a>:
<div class="highlight">
<pre><span class="nv">$ </span>heroku config:add <span class="nv">TWITTER_KEY</span><span class="o">=</span>&lt;your_twitter_consumer_key&gt; <span class="nv">TWITTER_SECRET</span><span class="o">=</span>&lt;your_twitter_consumer_secret&gt;
</pre>
</div>
After that, you should be able to deploy! :)

Get to it. Create a new Heroku application. Add Heroku as a git remote. Run <code>heroku config:add</code> to set up the Twitter key and secret. Push to Heroku.
