<script context="module">
 import client from "../../../../../apollo.js";
 import { ENDPOINTS_TESTS_AND_USERAGENTS, ALL_BUCKETS_AND_JOBS_SANS_LIVE } from '../../../../../queries';
 import { determineBucketAndJob } from '../../../../../lib/helpers.js';

 export async function preload (page, session) {
   let bucketAndJobsQuery = await client.query({query: ALL_BUCKETS_AND_JOBS_SANS_LIVE});
   let rawBucketsAndJobsPayload = bucketAndJobsQuery.data.bucket_job_swagger;
   let {
     query,
     params: {
       bucket: bucketParam,
       job: jobParam,
       level
       }
     } = page;
   let {bucket, job} = determineBucketAndJob(rawBucketsAndJobsPayload, bucketParam, jobParam);
   let endpointsTestsAndUseragentsFromQuery = await client.query({
     query: ENDPOINTS_TESTS_AND_USERAGENTS,
     variables: {bucket, job}
   });

   return {
     bucket,
     job,
     bucketParam,
     jobParam,
     level,
     endpointsTestsAndUseragentsFromQuery,
     query,
     rawBucketsAndJobsPayload
   };
 }
</script>

<script>
 import CoverageContainer from '../../../../../components/CoverageContainer.svelte';
 import {
   activeFilters,
   rawBucketsAndJobs,
   endpointsTestsAndUseragents,
   warnings
 } from '../../../../../stores';
 import { onMount, tick } from 'svelte';

 export let bucket;
 export let bucketParam;
 export let job;
 export let jobParam;
 export let level;
 export let endpointsUseragentsAndTestsFromQuery;
 export let rawBucketsAndJobsPayload;
 export let endpointsTestsAndUseragentsFromQuery;
 export let query;

 rawBucketsAndJobs.set(rawBucketsAndJobsPayload);
 activeFilters.update(af => ({...af, bucket, job, ...query, level}));
 endpointsTestsAndUseragents.set(endpointsTestsAndUseragentsFromQuery.data);
 onMount(() => {
   if (bucketParam && bucketParam !== bucket) {
     warnings.update(warnings => ({...warnings, invalidBucket: true}));
   }
   if (jobParam && jobParam !== job) {
     warnings.update(warnings => ({...warnings, invalidJob: true}));
   }
 })
</script>

{#if $warnings.invalidBucket}
<p><strong>Note: </strong><em>Could not find data for <code>{bucketParam}</code>. Displaying latest job for {bucket} instead.</em></p>
<button on:click={() => $warnings.invalidBucket = false}>Got it</button>
{/if}
{#if !$warnings.invalidBucket && $warnings.invalidJob}
<p><strong>Note: </strong><em>Could not find data for <code>{jobParam}</code>. Displaying latest job for {bucket} instead.</em></p>
<button on:click={() => $warnings.invalidJob = false}>Got it</button>
{/if}
<CoverageContainer />
