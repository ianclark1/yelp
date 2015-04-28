<!--- get your API key by signing up @ yelp --->
<cfset yelpAPIkey = "INSERT YELP API KEY HERE" />

<!--- 4158269189 henrys hunan in SF, CA--->
<cfset testphone = 4158269189>


<cfset yelpCFC = createObject("component", "yelp").init(yelpAPIkey)>

<!--- get all the business information for this record --->
<cfset getbiz = yelpCFC.getBusinessByPhone(testphone)>
<cfdump var="#getbiz#">
<!--- get the top 10 reviews based on their RSS feed --->
<cfset getReviewsByBusinessID = yelpCFC.getReviewsByBusinessID(getbiz.businesses[1].id)>

<!--- show the reviews --->
<cfloop from="1" to="#arrayLen(getReviewsByBusinessID)#" index="currentReview">
<cfoutput>
	<strong>#getReviewsByBusinessID[currentReview].rating#</strong> - #getReviewsByBusinessID[currentReview].NAME# @ #dateformat(getReviewsByBusinessID[currentReview].PUBDATE,"m/d/yy")#
	#getReviewsByBusinessID[currentReview].DESCRIPTION# <a href="#getReviewsByBusinessID[currentReview].LINK#">Read</a> 
	<br /><br />
</cfoutput>
</cfloop>

