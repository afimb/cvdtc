class ParametersService
  def initialize(job)
    @job = job
    @format = job.format.to_s
    @format_convert = job.format_convert.split('_')[1].to_s if job.format_convert.to_s['_']
  end

  def to_json
    base = {
      user_name: 'CVDTC',
      name: "Job #{@job.id}",
      organisation_name: 'AFIMB',
      references_type: 'line',
      referential_name: @job.referential,
      object_id_prefix: 'CVDTC'
    }
    if @format_convert
      {
        parameters: {
          convert: {
            "#{@format}-input": input_format_params,
            "#{@format_convert}-output": output_format_params
          }.merge!(base)
        }
      }.to_json
    else
      {
        parameters: {
          "#{@format}-validate": base,
        }.merge!(validate_params)
      }.to_json
    end
  end

  def self.param_value(key)
    ParametersService.validate_params_3[key.to_sym]
  end

  def validate_params
    return {} unless ENV['CHECK_GTE3'].present?
    {
      validation: { }.
        merge!(ParametersService.validate_params_3).
        # merge!(ParametersService.validate_params_4).
        merge!(@job.parameters)
    }
  end

  private

  def input_format_params
    return {} unless @format == 'gtfs'
    {
      object_id_prefix: @job.object_id_prefix,
      max_distance_for_commercial: @job.max_distance_for_commercial,
      ignore_last_word: @job.ignore_last_word,
      ignore_end_chars: @job.ignore_end_chars,
      max_distance_for_connection_link: @job.max_distance_for_connection_link
    }
  end

  def output_format_params
    return {} unless @format_convert == 'gtfs'
    {
      object_id_prefix: @job.object_id_prefix,
      time_zone: @job.time_zone
    }
  end

  def self.validate_params_3
    {
      stop_areas_area: [[-5.2, 42.25], [-5.2, 51.1], [8.23, 51.1], [8.23, 42.25], [-5.2, 42.25]],
      inter_stop_area_distance_min: 20,
      parent_stop_area_distance_max: 350,
      inter_access_point_distance_min: 20,
      inter_connection_link_distance_max: 800,
      walk_default_speed_max: 5,
      walk_occasional_traveller_speed_max: 4,
      walk_frequent_traveller_speed_max: 6,
      walk_mobility_restricted_traveller_speed_max: 2,
      inter_access_link_distance_max: 300,
      inter_stop_duration_max: 180,
      facility_stop_area_distance_max: 300,
      mode_coach: {
        inter_stop_area_distance_min: 500,
        inter_stop_area_distance_max: 10_000,
        speed_max: 90,
        speed_min: 40,
        inter_stop_duration_variation_max: 20,
        allowed_transport: 1
      },
      mode_air: {
        inter_stop_area_distance_min: 200,
        inter_stop_area_distance_max: 10_000,
        speed_max: 800,
        speed_min: 700,
        inter_stop_duration_variation_max: 60,
        allowed_transport: 1
      },
      mode_waterborne: {
        inter_stop_area_distance_min: 200,
        inter_stop_area_distance_max: 10_000,
        speed_max: 40,
        speed_min: 5,
        inter_stop_duration_variation_max: 60,
        allowed_transport: 1
      },
      mode_bus: {
        inter_stop_area_distance_min: 100,
        inter_stop_area_distance_max: 40_000,
        speed_max: 1000,
        speed_min: 5,
        inter_stop_duration_variation_max: 2000,
        allowed_transport: 1
      },
      mode_ferry: {
        inter_stop_area_distance_min: 200,
        inter_stop_area_distance_max: 10_000,
        speed_max: 40,
        speed_min: 5,
        inter_stop_duration_variation_max: 60,
        allowed_transport: 1
      },
      mode_walk: {
        inter_stop_area_distance_min: 1,
        inter_stop_area_distance_max: 10_000,
        speed_max: 6,
        speed_min: 1,
        inter_stop_duration_variation_max: 10,
        allowed_transport: 1
      },
      mode_metro: {
        inter_stop_area_distance_min: 300,
        inter_stop_area_distance_max: 20_000,
        speed_max: 500,
        speed_min: 25,
        inter_stop_duration_variation_max: 2000,
        allowed_transport: 1
      },
      mode_shuttle: {
        inter_stop_area_distance_min: 500,
        inter_stop_area_distance_max: 10_000,
        speed_max: 80,
        speed_min: 20,
        inter_stop_duration_variation_max: 10,
        allowed_transport: 1
      },
      mode_rapid_transit: {
        inter_stop_area_distance_min: 2000,
        inter_stop_area_distance_max: 500_000,
        speed_max: 300,
        speed_min: 20,
        inter_stop_duration_variation_max: 60,
        allowed_transport: 1
      },
      mode_taxi: {
        inter_stop_area_distance_min: 500,
        inter_stop_area_distance_max: 300_000,
        speed_max: 130,
        speed_min: 20,
        inter_stop_duration_variation_max: 60,
        allowed_transport: 1
      },
      mode_local_train: {
        inter_stop_area_distance_min: 2000,
        inter_stop_area_distance_max: 500_000,
        speed_max: 300,
        speed_min: 20,
        inter_stop_duration_variation_max: 60,
        allowed_transport: 1
      },
      mode_train: {
        inter_stop_area_distance_min: 2000,
        inter_stop_area_distance_max: 500_000,
        speed_max: 300,
        speed_min: 20,
        inter_stop_duration_variation_max: 60,
        allowed_transport: 1
      },
      mode_long_distance_train: {
        inter_stop_area_distance_min: 2000,
        inter_stop_area_distance_max: 500_000,
        speed_max: 300,
        speed_min: 20,
        inter_stop_duration_variation_max: 60,
        allowed_transport: 1
      },
      mode_tramway: {
        inter_stop_area_distance_min: 300,
        inter_stop_area_distance_max: 2000,
        speed_max: 50,
        speed_min: 20,
        inter_stop_duration_variation_max: 30,
        allowed_transport: 1
      },
      mode_trolleybus: {
        inter_stop_area_distance_min: 300,
        inter_stop_area_distance_max: 2000,
        speed_max: 50,
        speed_min: 20,
        inter_stop_duration_variation_max: 30,
        allowed_transport: 1
      },
      mode_private_vehicle: {
        inter_stop_area_distance_min: 500,
        inter_stop_area_distance_max: 300_000,
        speed_max: 130,
        speed_min: 20,
        inter_stop_duration_variation_max: 60,
        allowed_transport: 1
      },
      mode_bicycle: {
        inter_stop_area_distance_min: 300,
        inter_stop_area_distance_max: 30_000,
        speed_max: 40,
        speed_min: 10,
        inter_stop_duration_variation_max: 10,
        allowed_transport: 1
      },
      mode_other: {
        inter_stop_area_distance_min: 300,
        inter_stop_area_distance_max: 30_000,
        speed_max: 40,
        speed_min: 10,
        inter_stop_duration_variation_max: 10,
        allowed_transport: 1
      }
    }
  end

  def self.validate_params_4
    {
      check_allowed_transport_modes: 0,
      check_lines_in_groups: 0,
      check_line_routes: 0,
      check_stop_parent: 0,
      check_connection_link_on_physical: 0,
      check_network: 0,
      network: {
        objectid: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        name: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        registration_number: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        }
      },
      check_company: 0,
      company: {
        objectid: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        name: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        registration_number: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        }
      },
      check_group_of_line: 0,
      group_of_line: {
        objectid: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        name: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        registration_number: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        }
      },
      check_stop_area: 0,
      stop_area: {
        objectid: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        name: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        registration_number: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        city_name: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        country_code: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        zip_code: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        }
      },
      check_access_point: 0,
      access_point: {
        objectid: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        name: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        city_name: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        country_code: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        zip_code: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        }
      },
      check_access_link: 0,
      access_link: {
        objectid: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        name: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        link_distance: {
          unique: 0,
          min_size: '',
          max_size: ''
        },
        default_duration: {
          unique: 0,
          min_size: '',
          max_size: ''
        }
      },
      check_connection_link: 0,
      connection_link: {
        objectid: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        name: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        link_distance: {
          unique: 0,
          min_size: '',
          max_size: ''
        },
        default_duration: {
          unique: 0,
          min_size: '',
          max_size: ''
        }
      },
      check_time_table: 0,
      time_table: {
        objectid: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        comment: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        version: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        }
      },
      check_line: 0,
      line: {
        objectid: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        name: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        registration_number: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        number: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        published_name: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        }
      },
      check_route: 0,
      route: {
        objectid: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        name: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        number: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        published_name: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        }
      },
      check_journey_pattern: 0,
      journey_pattern: {
        objectid: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        name: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        registration_number: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        published_name: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        }
      },
      check_vehicle_journey: 0,
      vehicle_journey: {
        objectid: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        published_journey_name: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        published_journey_identifier: {
          unique: 0,
          pattern: 0,
          min_size: '',
          max_size: ''
        },
        number: {
          unique: 0,
          min_size: '',
          max_size: ''
        }
      }
    }
  end
end
