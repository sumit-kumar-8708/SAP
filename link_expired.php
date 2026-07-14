<?php

namespace App\Filters;

use CodeIgniter\Filters\FilterInterface;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use App\Models\CommonModel;
// use App\Services\CookieService;



class ProjectAuthFilter implements FilterInterface
{
    /**
     * Do whatever processing this filter needs to do.
     * By default it should not return anything during
     * normal execution. However, when an abnormal state
     * is found, it should return an instance of
     * CodeIgniter\HTTP\Response. If it does, script
     * execution will end and that Response will be
     * sent back to the client, allowing for error pages,
     * redirects, etc.
     *
     * @param RequestInterface $request
     * @param array|null       $arguments
     *
     * @return RequestInterface|ResponseInterface|string|void
     */
   public function before(RequestInterface $request, $arguments = null)
    {

        helper('project');
        $cache =service('cache');
        $uri = service('uri');
        $CookieService = \Config\Services::CookieService();
        // $CookieService = service('CookieService');
        // echo '<pre>';
        // print_r($CookieService);
        // die();
        $segments = $uri->getSegments();
        $method=  $request->getMethod();

        $projectAccessToken = $request->getVar('p_id') ?? '1';
        $common_model = new CommonModel();
        if (!(isset($segments[0]) && $segments[0] == 'link_expired')) {

            if ($projectAccessToken !== '') {
                // update the token to cookies
                $decodedProjectId = $projectAccessToken;


                // Fetch project details from the database
                $project_data = $common_model->getProjectDetails($decodedProjectId);
                if (!empty($project_data)) {

                    // $project_data_encode = base64_encode(json_encode($project_data));
                    // Fetch project module data from the database
                    $project_module_data = $common_model->getProjectUserComponents($decodedProjectId);
                    if (!empty($project_module_data)) {
                        
                        // $project_module_data_encode = base64_encode(json_encode($project_module_data));
                        $cache->delete('project_module'.$decodedProjectId); // delete old one 
                        $cache->delete('project_'.$decodedProjectId); // delete old one 
                        $expiresTime = 3600; // 300 seconds = 5 minutes
                        $cache->save('project_'.$decodedProjectId,  $project_data, $expiresTime); 
                        $cache->save('project_module_'.$decodedProjectId,  $project_module_data, $expiresTime); 
                        /**
                         *  store cookies 
                         */
                        $CookieService::set(
                            'pi',
                            $decodedProjectId,
                            $expiresTime
                        );
                        session()->set(['pi'=>$decodedProjectId]);

                        // CookieService::set(
                        //     'pd',
                        //     $project_data_encode,
                        //     $expiresTime
                        // );
                        // CookieService::set(
                        //     'pmd',
                        //     $project_module_data_encode,
                        //     $expiresTime
                        // );
                    }
                }
            }
            /**
             *  
             *  check cookies and validate cookies
             *  
             */

            // $projectId = session()->get('pi') ?? 0;
            // if($projectId==0){
            //     $projectId =  $CookieService::get('pi') ?? 0; 
            //     if($projectId>0){
            //          session()->set(['pi'=>$projectId]);
            //     }
            // }
            $projectId= $common_model->getCacheProjectId();
            // $project_data_encode = CookieService::get('pd') ?? '';
            // $project_module_data_decode = CookieService::get('pmd') ?? '';
            // echo $project_module_data_decode;
            // $project_module_data = [];
            // $project_data = [];
            // if (isset($project_data_encode)  && !empty($project_data_encode)) {
            //     $project_data = json_decode(base64_decode($project_data_encode), true);
            // }
            // if (isset($project_module_data_decode)  && !empty($project_module_data_decode)) {
            //     $project_module_data = json_decode(base64_decode($project_module_data_decode), true);
            // }
             // get data from cache
            $project_data=  $cache->get('project_'.$projectId); 
            $project_module_data=  $cache->get('project_module_'.$projectId); 
            if ($projectId <= 0 || !$project_data || !$project_module_data) {
                return redirect()->to(base_url('link_expired?k=1'));
            }

            /**
             *  Authorize pages and action based on the component enable or not
             */
            $is_page_authorize=validate_allows_routes($segments,'page');
            if(!$is_page_authorize){
                
                return redirect()->to(url_to('home'));
                
            }
            $is_action_authorize=validate_allows_routes($segments,'action');
            
            if(!$is_action_authorize){
               return service('response')->setJSON(['status'=>false, 'message'=>'Unauthorized Access']);
            }
        }
      }


    /**
     * Allows After filters to inspect and modify the response
     * object as needed. This method does not allow any way
     * to stop execution of other after filters, short of
     * throwing an Exception or Error.
     *
     * @param RequestInterface  $request
     * @param ResponseInterface $response
     * @param array|null        $arguments
     *
     * @return ResponseInterface|void
     */
    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
        /**
         *  
         *  clear cookies cache after page load;
         */
        // 
        $CookieService = \Config\Services::CookieService();
        $CookieService::clearCache('pi');
        // CookieService::clear('pmd');
        // $CookieService::clearCache('pd');
        // $decodedProjectId = CookieService::get('pi') ?? 0;
        // echo '<script>console.log(' . $decodedProjectId . ')</script>';
       
        

    }
}


?>