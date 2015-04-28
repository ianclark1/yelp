<!--- 
v .1 - alpha
Created By Jeff Gladnick, http://www.gladnickconsulting.com
 --->

<cfcomponent output="false" displayname="yelp" hint="Connects to Yelp's API">
	
	<cffunction name="init" access="public" returntype="any" hint="constructor">
		<cfargument name="yelpAPIKey" required="true" hint="alphanumeric API key that you need to get from yelp">
	
		<cfset variables.yelpAPIKey = arguments.yelpAPIKey />
	
		<cfreturn this />
	</cffunction>
	
	
	<cffunction name="getBusinessByPhone" access="public" returntype="struct" hint="Retrieves a yelp business record (JSON) based on the business phone number">
		<cfargument name="phone" type="numeric" required="true" hint="Phone number for the business.  NUMBERS ONLY!" />
		
		<cfset var businessInfo = "" />
		<cfset var cfhttp = 0 />
		
		<!--- connec to yelp's API to get the business info based on the phone number --->
		<cfhttp url="http://api.yelp.com/phone_search?phone=#arguments.phone#&ywsid=#variables.yelpAPIKey#" method="GET">
		
		<!--- De-Serialize (convert from Javascript JSON to CF Struct) the JSON object returned by yelp --->
		<cfset businessInfo = DeserializeJSON(cfhttp.filecontent) />	
		
		<!--- pass back our business info --->
		<cfreturn businessInfo />

	</cffunction>
	

	
	<cffunction name="getReviewsByPhone" access="public" returntype="array" hint="Just gets a sample array of reviews for a business based on the business phone number">
		<cfargument name="phone" type="numeric" required="true" hint="Phone number for the business.  NUMBERS ONLY!, ie: 4154443434" />
		
		<!--- get the entire business info struct --->
		<cfset var businessInfo = getBusinessByPhone(arguments.phone) />
				
		<cfreturn businessInfo.businesses[1].reviews />

	</cffunction>
	
	
	<cffunction name="getReviewsByBusinessID" access="public" returntype="any" hint="Gets the top yelp arrays based on an RSS feed">
		<cfargument name="businesID" type="string" required="true" hint="Unique alphamnumeric yelp ID for the business. ie: t0nXh1Nj5WIhg2CZDGyktA" />
		
		<cfset var cfhttp = 0 />
		<cfset var xml = 0 />
		<cfset var reviews = 0 />
		<cfset var currentItem = 0 />
		<cfset var returnArray = ArrayNew(1) />
				
		<!--- connect to yelp's API to get the business info based on the phone number --->
		<cfhttp url="http://www.yelp.com/syndicate/biz/#arguments.businesID#/rss.xml" method="GET">

		<!--- parse the xml --->
		<cfset xml = xmlparse(cfhttp.filecontent) />

		<!--- sort out just the array of reviews --->
		<cfset reviews = XMLSearch(xml, "/rss/channel/item")>

		<!--- loop through our XML array and convert everything into a coldfusion array of structs --->	
		<cfloop from="1" to="#arraylen(reviews)#" index="currentItem">
			<cfset returnArray[currentItem] = structNew() />
			<cfset returnArray[currentItem].description = reviews[currentItem].description.XmlText />
			<cfset returnArray[currentItem].link = reviews[currentItem].link.XmlText />
			<cfset returnArray[currentItem].pubDate = reviews[currentItem].pubDate.XmlText />
			
			<cfset tempTitle = reviews[currentItem].title.XmlText />

			<!--- last names are abbreviated with a period, so we stop there for the name --->
			<cfset periodPosition = find(".",tempTitle,1) />

			<!--- separate the name --->
			<cfset returnArray[currentItem].name = left(tempTitle,periodPosition) />

			<!--- separate the rating --->
			<cfset returnArray[currentItem].rating = mid(tempTitle,periodPosition+3,1) />
		</cfloop>

		<cfreturn returnArray />			

	</cffunction>
			

</cfcomponent>