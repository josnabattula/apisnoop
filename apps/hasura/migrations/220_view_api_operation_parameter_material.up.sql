-- Create
-- Using our api_operation_material view, look into the parameters field in each one.     
-- #+NAME: api_operation_parameter_material view

CREATE MATERIALIZED VIEW "public"."api_operation_parameter_material" AS 
  SELECT api_operation.operation_id AS param_op,
  (param.entry ->> 'name'::text) AS param_name,
         -- for resource:
         -- if param is body in body, take its $ref from its schema
         -- otherwise, take its type
         replace(
           CASE
           WHEN ((param.entry ->> 'in'::text) = 'body'::text) 
            AND ((param.entry -> 'schema'::text) is not null)
             THEN ((param.entry -> 'schema'::text) ->> '$ref'::text)
           ELSE (param.entry ->> 'type'::text)
           END, '#/definitions/','') AS param_schema,
         CASE
         WHEN ((param.entry ->> 'required'::text) = 'true') THEN true
         ELSE false
          END AS required,
         (param.entry ->> 'description'::text) AS param_description,
         CASE
         WHEN ((param.entry ->> 'uniqueItems'::text) = 'true') THEN true
         ELSE false
         END AS unique_items,
         (param.entry ->> 'in'::text) AS "in",
         api_operation.bucket,
         api_operation.job,
         param.entry as entry
    FROM api_operation
         , jsonb_array_elements(api_operation.parameters) WITH ORDINALITY param(entry, index)
          WHERE api_operation.parameters IS NOT NULL;

-- Index
-- #+NAME: index the api_operation_material

-- CREATE UNIQUE INDEX                                  ON api_operation_parameter_material(raw_swagger_id, param_op, param_name);
CREATE INDEX api_parameters_materialized_schema      ON api_operation_parameter_material            (param_schema);
-- CREATE INDEX api_parameters_materialized_entry       ON api_operation_parameter_material            (entry);